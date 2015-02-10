# encoding: utf-8

class Deal < ActiveRecord::Base
  include ActionView::Helpers::UrlHelper

  attr_accessible :buyer_id, :supplier_id, :title, :archive, :supplier_archive
  attr_readonly :buyer_id

  belongs_to :buyer, class_name: 'Contractor', foreign_key: 'buyer_id'
  belongs_to :supplier, class_name: 'Contractor', foreign_key: 'supplier_id'

  has_one :tender, dependent: :destroy # уточнить, можно ли удалять совсем
  has_one :cost_calculation, dependent: :destroy
  has_one :sea_freight, dependent: :destroy
  
  scope :successful, -> {where(successful: true)}
  scope :unsuccessful, -> {where(successful: false)}
  scope :archived, -> {where(archive: true)}
  scope :not_archived, -> {where(archive: false)}
  scope :not_supplier_archived, -> {where(supplier_archive: false)}
  
  scope :current, -> {where("state IN (?)", ['tender_state', 'cost_calculation'])}
  scope :by_updated, -> {order("updated_at DESC")}

  state_machine :initial => :new do
    #states
    state :new do
      def current_task
        'новый'
      end
      def current_task_state
        '-'
      end
      def end_date
        '-'
      end
    end
    state :tender_state do
      def current_task_state
        tender.try(:current_state)
      end
      def end_date
        if tender.try(:completed?)
          tender.end_at
        else
          'активный'
        end
      end
    end
    state :cost_calculation do
      def current_task
        cost_calculation_deal_link
      end
      def current_task_state
        cost_calculation.try(:current_state)
      end
      def end_date
        'активный'
      end
    end

    state :sea_freight do
      def current_task
        "sea_freight"
      end
      def current_task_state
        'sea_freight'
      end
      def end_date
        'активный'
      end
    end

    state :successful do
      def current_task_state
        cost_calculation.try(:current_state) || tender.try(:current_state)
      end
      def end_date
        tender.try(:end_at) || 'активный'
      end
    end
    state :unsuccessful do
      def current_task_state
        cost_calculation.try(:current_state) || tender.try(:current_state)
      end
      def end_date
        tender.try(:end_at)  || 'активный'
      end
    end
    state :successful, :unsuccessful do
      def completed?
        true
      end
    end
    state all - [:successful, :unsuccessful] do
      def completed?
        false
      end
    end
    #events
    event :to_cost_calculation do
      transition [:new, :tender_state, :successful] => :cost_calculation
    end
    event :to_tender do
      transition new: :tender_state
    end
    event :to_sea_freight do
      transition new: :sea_freight
    end
    event :success do
      transition [:tender_state, :cost_calculation] => :successful
    end
    event :unsuccess do
      transition [:tender_state, :cost_calculation] => :unsuccessful
    end
  end

  def current_task_states
    if archive?
      'архив'
    else
      current_task_state
    end
  end

  def new_in_all_states?
    (tender_state? && tender.try(:new?)) || ((cost_calculation? && cost_calculation.try(:new?)) && tender.nil?) || try(:new?)
  end

  def current_task
    if tender.presence && cost_calculation.presence
      "#{tender.try(:deal_link)}. #{cost_calculation.try(:deal_link)}"
    else
      cost_calculation.try(:deal_link) || tender.try(:deal_link)
    end
  end

  def self.active_for_supplier(current_contractor)
    deals_ids = current_contractor.tenders.for_supplier.collect(&:deal_id)
    deals_ids << current_contractor.cost_calculations.collect(&:deal_id)
    self.order("created_at DESC").where('id IN (?)', deals_ids.flatten)
  end

  def self.archived_for_supplier(current_contractor)
    deals_ids = current_contractor.tenders.archive.collect(&:deal_id)
    deals_ids << current_contractor.cost_calculations.completed.collect(&:deal_id)
    self.order('created_at DESC').where('id IN (?)', deals_ids.flatten)
  end

  def index(contractor)
    contractor.deals.to_a.find_index{ |x| x.id == self.id } + 1
  end

  def owner
    buyer
  end

  def big_id
    id + 120
  end

  def participator?(current_contractor)
    buyer == current_contractor || supplier == current_contractor
  end

  def owner?(current_contractor)
    buyer == current_contractor
  end

  def current?
    successful.nil?
  end

  def completed?
    successful.presence
  end

  def self.create_for_calculation(current_contractor)
    deal = Deal.new
    if current_contractor.buyer?
      deal.buyer = current_contractor
    else
      deal.supplier = current_contractor
    end
    deal.to_cost_calculation
    deal.save
    deal
  end
end

