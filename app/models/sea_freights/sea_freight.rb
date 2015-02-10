# encoding: utf-8

class SeaFreight < ActiveRecord::Base
  FAKE_PARTICIPANTS = 3

  attr_accessible :customs_clearance, :description, :destination, :destination_port, :hazard, :incoterms, :loading_date, :requirements, :shipping_place, :shipping_port, :state, :title, :transport, :step, :contractor_id, :deal_id, :transport_units_attributes, :status, :ready, :winner_id, :start_date, :end_date, :own_hazard, :any_port, :end_at, :failure_cause
  attr_accessor :ready, :own_hazard, :any_port

  belongs_to :deal
  belongs_to :contractor
  belongs_to :winner, class_name: 'SeaFreightResponse', foreign_key: 'winner_id'

  has_many :project_contractors, as: :projectable, dependent: :destroy

  validates :transport, :loading_date, :title, :incoterms, :end_at,  presence: true, on: :update

  validates :customs_clearance, :destination, presence: true, on: :update, if: Proc.new { |s| s.current_transport?(:any_transport) }
  validate :any_transports, on: :update, if: Proc.new { |s| s.current_transport?(:any_transport) }

  validates :shipping_port, :destination_port, presence: true, on: :update, if: Proc.new { |s| s.current_transport?(:sea) }

  validates :shipping_port, :customs_clearance, :destination, presence: true, on: :update, if: Proc.new { |s| s.current_transport?([:sea_auto, :sea_railway, :railway])}

  has_many :transport_units, as: :transportable, dependent: :destroy

  has_many :notifications, as: :notifiable, dependent: :destroy

  has_many :messages, as: :messagable, dependent: :destroy

  belongs_to :exchange_rate

  has_many :project_contractors, as: :projectable, dependent: :destroy

  has_one :sea_freight_execution_sea_auto, as: :vedable, dependent: :destroy
  has_one :sea_freight_execution_sea, as: :vedable, dependent: :destroy
  has_one :sea_freight_execution_sea_railway, as: :vedable, dependent: :destroy
  has_one :sea_freight_execution_railway, as: :vedable, dependent: :destroy

  has_many :sea_freight_responses, dependent: :destroy
  has_one :offline_offer, class_name: 'SeaFreight::OfflineOffer'

  scope :sent, -> { where('state = ? OR state = ? OR state = ? OR state = ? OR state = ?', 'waiting', 'active', 'decision', 'successful', 'unsuccessful') }
  scope :not_new, -> { where('state = ? OR state = ? OR state = ? OR state = ? OR state = ? OR state = ?', 'new', 'waiting', 'active', 'decision', 'successful', 'unsuccessful') }

  scope :waiting_for_approving, -> { where(state: 'waiting') }
  scope :overdue, -> { where('end_date < ?', Time.now.beginning_of_day + 9.hours + 1.day).where('state IN (?)', ['active', 'decision']).order('end_date DESC') }

  before_save :set_hazard
  accepts_nested_attributes_for :transport_units, allow_destroy: true

  validates_acceptance_of :ready, if: -> { current_step?('active') }

  # state machine
  state_machine initial: :new do
    after_transition on: :to_form, do: :add_project
    before_transition on: :approve, do: :set_exchange
    after_transition on: [:stop, :set_winner, :reject_all], do: :end_project

    state :new
    state :form
    state :waiting
    state :active
    state :decision
    state :successful
    state :unsuccessful

    # events
    event :to_form do
      transition new: :form
    end

    event :to_myved do
      transition form: :waiting
    end

    event :approve do
      transition waiting: :active
    end

    event :stop do
      transition active: :decision
    end

    event :set_winner do
      transition [:active, :decision] => :successful
    end

    event :reject_all do
      transition [:active, :decision] => :unsuccessful
    end

    # states
    state all - [:new, :waiting] do
      def approved?
        true
      end
    end

    state :new, :waiting do
      def approved?
        false
      end
    end

    state all - [:successful, :unsuccessful] do
      def completed?
        false
      end
    end

    state :successful, :unsuccessful do
      def completed?
        true
      end
    end

  end
  # end state machine

  def state_string
    I18n.t("statuses.sea_freight.#{state}")
  end

  def current_step?(step)
    status == step || active?
  end

  def self.currency_options
    [
      ['USD', 'usd'],
      ['euro', 'euro'],
      ['руб.', 'rub']
    ]
  end

  def sea_auto?
    transport == 'sea_auto'
  end

  def self.hazard_options
    arr = [['не опасный', 'no']]
    9.times.each do |i|
      arr <<  ["Класс #{i + 1}", "class_#{i + 1}"]
    end
    arr
  end

  def self.requirements_options
    [
      ['оптимальное соотношение стоимости и срока доставки', 'terms_price'],
      ['короткие сроки доставки', 'terms'],
      ['низкая стоимости доставки', 'price']
    ]
  end

  def self.incoterms_options
    { '1.Группа E Отгрузка' => ['EXW'],
      '2.Группа F Основная перевозка не оплачена продавцом' => %w(
        FCA
        FAS
        FOB),
      '3.Группа C Основная перевозка оплачена продавцом' => %w(
        CFR
        CIF
        CPT
        CIP),
      '4.Группа D Доставка' => %w(
        DAP
        DAT
        DDP)
    }
  end

  def owner?(current_contractor)
    contractor == current_contractor
  end

  def set_dates
    self.start_date = Time.now
    self.end_date = self.end_at
    save
  end

  def subject
    full_title
  end

  def full_title
    "#{title} - №#{id}"
  end

  def wait_decision?
    decision?
  end

  def has_winner?
    winner_id.presence
  end

  def can_reject?
    %w(active decision).include?(state)
  end

  def set_hazard
    return '' unless own_hazard.presence
    self.hazard = own_hazard
  end

  def can_response?(cur_contractor_id)
    sea_freight_responses.where(contractor_id: cur_contractor_id).presence
  end

  def send_best_notifications(resp)
    if resp.best?
      notifications.build(contractor_id: contractor_id).set_body(:new_best_response, resp)
      sea_freight_responses.each do |sfr|
        notifications.build(contractor_id: sfr.contractor_id).set_body(:new_best_response_to_contractors, resp)
      end
    else
      notifications.build(contractor_id: contractor_id).set_body(:new_response, resp)
    end
  end

  def winner_contactor
    winner.contractor
  end

  def any_transport?
    current_transport?('any_transport')
  end

  def current_transport?(transports)
    [transports].flatten.map(&:to_s).include?(transport)
  end

  def sea_freight_execution
    sea_freight_execution_sea_auto || sea_freight_execution_sea || sea_freight_execution_sea_railway || sea_freight_execution_railway
  end

  def sea?
    ['sea', 'sea_auto', 'sea_railway', 'any_transport'].include?(transport)
  end

  def auto?
    ['sea_auto', 'railway', 'sea_railway', 'any_transport'].include?(transport)
  end

  def railway?
    ['railway', 'sea_railway', 'any_transport'].include?(transport)
  end

  def self.transport_options
    [
      ['сравнить маршруты (море, авто, жд)', 'any_transport'],
      ['доставка до порта (море)', 'sea'],
      ['доставка до места (море + авто)', 'sea_auto'],
      ['доставка до места (море + ж/д)', 'sea_railway'],
      ['прямая ж/д доставка (ж/д)', 'railway']
    ]
  end

  private

  def any_transports
    unless shipping_place.present? || shipping_port.present?
      errors[:base] << 'необходимо выбрать либо порт отгрузки либо место отгрузки'
    end
  end

  def set_exchange
    self.exchange_rate = ExchangeRate.by_actual.first
  end

  def add_project
    project_contractors.create(contractor_id: contractor_id).to_current
  end

  def end_project
    project_contractors.not_ended.each do |pc|
      pc.update_attributes(end_at: Time.now)
    end
  end
end
