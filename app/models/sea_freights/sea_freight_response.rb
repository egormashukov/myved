# encoding: utf-8
class SeaFreightResponse < ActiveRecord::Base
  attr_accessible :sea_freight_id, :company, :fifo, :filo, :port_charges, :tracking, :end_date, :transit, :free_container, :free_port, :free_car, :stoppage, :overbalance, :additional_charges, :max_weight, :contractor_id, :destination_port, :railway_charges, :filo_currency, :port_charges_currency, :railway_charges_currency, :tracking_currency, :railway_charges_vat, :category, :total, :filo_vat, :port_charges_vat, :tracking_vat

  validates :sea_freight_id, :category, :contractor_id, :end_date, :transit, :free_container, presence: true, on: :update

  validates :filo, :port_charges, :railway_charges, :tracking, numericality: { greater_than: 0, allow_nil: true }

  validates :filo, presence: true, on: :update, if: Proc.new { |s| s.current_transport?(:sea) }
  validates :filo, :port_charges, :tracking, presence: true, on: :update, if: Proc.new { |s| s.current_transport?(:sea_auto) }

  validates :filo, :railway_charges, presence: true, on: :update, if: Proc.new { |s| s.current_transport?(:sea_railway) }

  validates :railway_charges, presence: true, on: :update, if: Proc.new { |s| s.current_transport?(:railway) }

  # validates :filo, :free_port, presence: true, if: :sea?, on: :update

  validates :stoppage, :free_car, :destination_port, presence: true, if: :auto?, on: :update

  # validates :railway_charges, presence: true, if: :railway?, on: :update

  validate :updated_only_three_time, on: :update
  validate :category_validation, on: :update, unless: :any_transport?

  scope :activated, -> { where('state = ? OR state = ? OR state = ?', 'active', 'winner', 'loser') }

  scope :overdue, -> { where('created_at < ?', Time.now.beginning_of_day + 1.day).where(state: 'new').where('contractor_id > ?', 0).order('created_at DESC') }

  before_update :set_total
  before_validation :set_category, unless: :any_transport?

  attr_accessor :ready
  belongs_to :sea_freight
  belongs_to :contractor

  after_create :send_invitations

  # state machine
  state_machine initial: :new do
    state :new
    state :active
    state :winner
    state :loser

  #events
    event :approve do
      transition new: :active
    end

    event :win do
      transition active: :winner
    end

    event :lose do
      transition active: :loser
    end

  #states
  end
  # end state machine

  def state_string
    I18n.t("statuses.sea_freight_response.#{state}")
  end

  def self.by_total
    order(:total)
  end

  def currency_of(field)
    try("#{field}_currency".to_sym)
  end

  def charges_to_usd(field)
    (try(field) || 0.0) * (sea_freight.exchange_rate.try("#{currency_of(field) || 'usd'}_usd".to_sym))
  end

  def sea_auto?
    sea_freight.try(:transport) == 'sea_auto'
  end

  def best?
    sea_freight.sea_freight_responses.best == self
  end

  def self.best
    activated.by_total.first
  end

  def owner?(current_contractor)
    contractor_id == current_contractor.id
  end

  def send_invitations
    sea_freight.notifications.build(contractor_id: contractor_id).set_body(:invitation)
  end

  def self.by_contractor(contractor)
    where(contractor_id: contractor.id).first
  end

  def increment_updated_count
    self.updated_count += 1 if active? && valid?
    true
  end

  def full_title
    sea_freight.full_title
  end

  def self.activated_with_messages
    sea_freight = self.first.try(:sea_freight)
    with_messages_arrays = sea_freight.present? ? sea_freight.messages.collect(&:sender_id) : []
    where('state = ? OR state = ? OR state = ? OR contractor_id IN (?)', 'active', 'winner', 'loser', with_messages_arrays)
  end

  def selected_transport_option
    category.presence || (sea_freight.transport == 'any_transport' ? 'sea_auto' : sea_freight.transport)
  end

  def self.category_options
    [
      ['доставка до порта', 'sea'],
      ['морская доставка + автовывоз', 'sea_auto'],
      ['морская доставка + ж/д', 'sea_railway'],
      ['ж/д доставка', 'railway']
    ]
  end

  def sea?
    current_transport? ['sea', 'sea_auto', 'sea_railway']
  end

  def auto?
    current_transport? ['sea_auto', 'railway', 'sea_railway']
  end

  def railway?
    current_transport? ['railway', 'sea_railway']
  end

  def current_transport?(transports)
    [transports].flatten.map(&:to_s).include?(category)
  end

  def any_transport?
    sea_freight.current_transport?('any_transport')
  end

  private

  def set_category
    self.category = sea_freight.transport
  end

  def category_validation
    return '' if category == sea_freight.transport
    errors.add :category, "должен быть: #{sea_freight.decorate.transport_string}"
  end

  def updated_only_three_time
    return '' if updated_count <= 3
    errors[:base] << I18n.t('activerecord.errors.sea_freight_response.three_times')
  end

  def set_total
    self.total = ((charges_to_usd(:filo) || 0) + (charges_to_usd(:port_charges) || 0) + (charges_to_usd(:tracking) || 0) + (charges_to_usd(:railway_charges) || 0)).presence
  end
end
