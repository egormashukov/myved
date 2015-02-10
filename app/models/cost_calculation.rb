# encoding: utf-8

class CostCalculation < ActiveRecord::Base
  default_scope includes(:cost_calculation_execution)
  
  include ActionView::Helpers::UrlHelper
  attr_accessible :title, :conditions_of_supply, :deal_id, :destination, :shipment_port, :terms_of_payment, :currency, :transport_units_attributes, :contractor_id, :status, :note, :accepted, :failure_cause

  has_many :supplier_products, :through => :cost_calculation_products
  has_many :cost_calculation_products, dependent: :destroy, inverse_of: :cost_calculation
  has_one :cost_calculation_response

  has_one :cost_calculation_execution, as: :vedable, dependent: :destroy
  has_many :transport_units, as: :transportable, dependent: :destroy

  has_many :project_contractors, as: :projectable, dependent: :destroy

  belongs_to :contractor
  belongs_to :deal

  validates_presence_of :title, :conditions_of_supply, :destination, :shipment_port, :terms_of_payment, :currency, if: lambda {|t| current_step?('general_info')}

  validate :must_have_products, if: lambda {|t| current_step?('products')}
  #validate :currency_readonly, if: lambda {|t| current_step?('general_info')}
  scope :except_new, -> { where('state = ? OR state = ? OR state = ? OR state = ? OR state = ?', 'form', 'waiting', 'answered', 'accepted', 'declined') }

  scope :admin, -> { where('state = ? OR state = ? OR state = ? OR state = ?', 'waiting', 'answered', 'accepted', 'declined') }
  scope :active, -> { where('state = ? OR state = ?', 'waiting', 'answered') }
  scope :completed, -> { where(state: 'completed') }

  scope :waiting_for_approving, -> { where(state: 'waiting') }
  
  has_many :notifications, as: :notifiable, dependent: :destroy
  has_many :transport_units, as: :transportable, dependent: :destroy
  accepts_nested_attributes_for :transport_units, allow_destroy: true
  
  #state machine
  state_machine initial: :new do
    after_transition on: :to_form, do: :add_project
    after_transition on: [:accept, :decline], do: :end_project

    state :new do
      def current_state
        I18n.t('statuses.cost_calculation.new')
      end
      def completed?
        false
      end
    end
    state :form do
      def current_state
        I18n.t('statuses.cost_calculation.form')
      end
      def completed?
        false
      end
    end
    state :waiting do
      def current_state
        I18n.t('statuses.cost_calculation.waiting')
      end
      def completed?
        false
      end
    end
    state :answered do
      def current_state
        I18n.t('statuses.cost_calculation.answered')
      end
      def completed?
        false
      end
    end
    state :accepted do
      def current_state
        I18n.t('statuses.cost_calculation.accepted')
      end
      def completed?
        true
      end
    end
    state :declined do
      def current_state
        I18n.t('statuses.cost_calculation.declined')
      end
      def completed?
        true
      end
    end
  #events
    event :to_form do
      transition new: :form
    end
    event :send_to_ns do
      transition form: :waiting
    end
    event :answer do
      transition waiting: :answered
    end
    event :accept do
      transition answered: :accepted
    end
    event :decline do
      transition answered: :declined
    end
  #callbacks
    after_transition on: :send_to_ns do |cost_calc|
      cost_calc.notifications.build(contractor_id: cost_calc.contractor_id).set_body(:created)
      cost_calc.notifications.build(contractor_id: Contractor.ns.id).set_body(:created_to_myved)
      cost_calc.create_cost_calculation_execution(contractor_id: cost_calc.contractor_id )
    end

    after_transition on: :accept do |cost_calc|
      cost_calc.notifications.build(contractor_id: cost_calc.contractor_id).set_body(:accept)
      cost_calc.notifications.build(contractor_id: Contractor.ns.id).set_body(:accept_to_myved)
    end
    after_transition on: :decline do |cost_calc|
      cost_calc.notifications.build(contractor_id: Contractor.ns.id).set_body(:decline_to_myved)
    end

  end
#

  def current_step?(step)
    (status == step) || waiting? || completed? || active?
  end

  def summ_cost
    cost_calculation_products.inject(0) {|sum, i| sum + i.summ_cost}
  end

  def active?
    status == "active"
  end

  def deal_link
    if active?
      "#{CostCalculation.model_name.human}: \"#{link_to(self.try(:title) || I18n.t(:no_title), '/cost_calculations/' + self.id.to_s)}\""
    else
      "#{CostCalculation.model_name.human}: \"#{link_to(self.try(:title)  || I18n.t(:no_title), '/cost_calculations/' + id.to_s + '/build/' + (status || 'general_info'))}\""
    end
  end

  def owner?(current_contractor)
    contractor_id == current_contractor.id
  end

  def dublicate_products(tender_response, current_contractor)
    tender_response.product_responses.each do |product_response|
      sp = current_contractor.supplier_products.create(accessible_attrs_hash(product_response.supplier_product))
      product_response.supplier_product.properties.each do |p|
        sp.properties.create(accessible_attrs_hash(p))
      end
      cost_calculation_products.create(price: product_response.price, quantity: product_response.product_request.quantity, quantity_unit: product_response.product_request.quantity_unit, supplier_product_id: sp.id)
    end
  end

  def self.currency_options
    ["$", "&euro;"]
  end

  def tender
    deal.try(:tender)
  end

  def has_deal?
    deal.presence
  end

  def has_tender?
    tender.presence
  end

  def avia?
    transport == 'авиа'
  end

  def contractor_title
    contractor.title
  end

  def accessible_attrs_hash(obj)
    attrs = obj.attributes
    classname = eval(obj.class.name)
    protected_attrs = classname.new.attributes.keys - classname.accessible_attributes.to_a
    protected_attrs.each do |pa|
      attrs.delete(pa)
    end
    attrs
  end

  def failure_cause_txt
    CostCalculation::Decline.failure_cause_options.detect{|fco| fco[1] == self.failure_cause}.try(:first) || "причина не указана" 
  end

  def subject
    "#{CostCalculation.model_name.human}. #{title}"
  end

  private

  def add_project
    project_contractors.create(contractor_id: contractor_id)
  end

  def end_project
    project_contractors.not_ended.each do |pc|
      pc.update_attributes(end_at: Time.now)
    end
  end

  def must_have_products
    if cost_calculation_products.empty?
      errors.add :cost_calculation_products, 'amount must be greater than 0'
    end
  end

  def currency_readonly
    if currency_changed?
      errors.add :currency, 'не может быть изменена'
    end
  end

end
