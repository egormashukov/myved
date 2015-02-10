# encoding: utf-8
class Contractor::Authorization < Contractor
  attr_accessible :state, :step, :doc_by_law, :doc_ogrn, :doc_inn, :doc_egrul, :doc_director, :doc_proxy, :doc_by_law_cache, :doc_ogrn_cache, :doc_inn_cache, :doc_egrul_cache, :doc_director_cache, :doc_proxy_cache, :authorized

  has_one :authorization_execution, dependent: :destroy, as: :vedable
  has_many :project_contractors, as: :projectable, dependent: :destroy

  has_many :auth_notifications, as: :notifiable, dependent: :destroy, class_name: 'Notification'
  has_many :messages, as: :messagable, dependent: :destroy

  validates :business_kind, :number, :country, :shipment_types, presence: true, if: -> { current_step?('general_info') }
  validates :direction, presence: true, if: -> { current_step?('general_info') && buyer? }
  validates :pattern_of_ownership, :director, :legal_address, :register_number, :foundation_year, presence: true, if: -> { current_step?('legacy_info') }
  validates :doc_by_law, :doc_ogrn, :doc_inn, :doc_egrul, presence: true, if: -> { current_step?('documents') }

  validates :bank_title, :bic, :settlement_account, :correspondent_account, presence: true, if: -> { current_step?('legacy_info') && russian? }
  validates :foreign_bank_title, :foreign_bank_address, :foreign_bank_swift, :foreign_bank_account_number, presence: true, if: -> { current_step?('legacy_info') && !russian? }

  scope :sent, -> { where('state = ? OR state = ?', 'form', 'execution') }

  state_machine initial: :new do

    before_transition on: :to_form do |auth|
      Notification.new(contractor_id: Contractor.ns.id, notifiable_type: 'Contractor::Authorization', notifiable_id: auth.id).set_body(:to_form_to_myved)
    end

    before_transition on: :to_execution do |auth|
      auth.create_authorization_execution(contractor_id: auth.id)
      Notification.new(contractor_id: Contractor.ns.id, notifiable_type: 'Contractor::Authorization', notifiable_id: auth.id).set_body(:to_execution)
      Notification.new(contractor_id: Contractor.ns.id, notifiable_type: 'Contractor::Authorization', notifiable_id: auth.id).set_body(:to_execution)
    end

    before_transition on: :authorize do |auth|
      auth.update_attributes(authorized: true)
      auth.authorization_execution.complete
      Notification.new(contractor_id: auth.id, notifiable_type: 'Contractor::Authorization', notifiable_id: auth.id).set_body(:authorize)
    end

    state :new
    state :form
    state :execution
    state :successful

    # events

    event :to_form do
      transition new: :form
    end

    event :to_execution do
      transition form: :execution
    end

    event :authorize do
      transition execution: :successful
    end
  end

  def contractor
    Contractor.ns
  end

  def completed?
    successful?
  end

  def subject
    "Авторизация: #{title}"
  end

  def state_string
    I18n.t("statuses.contractor/authorization.#{state}")
  end

  def current_step?(current_step)
    step == current_step || active?
  end

  def active?
    step == 'active'
  end
end
