# encoding: utf-8

class Tender < ActiveRecord::Base
  default_scope includes(:owner)
  include ActionView::Helpers::UrlHelper

  #constants
  REMINDER_END_AFTER =  3
  REMINDER_ANSWERS_AFTER = 3

  NEW_END_DATE_BY = 2
  AUTOCLOSE_AFTER = 3

  PROLONG_AFTER = 4
  PROLONGATION_BY = 3

  #attrs
  attr_accessible :deal_id, :title, :start_at, :end_at, :duration, :body, :currency, :delivery_time, :terms_of_payment, :conditions_of_supply, :service, :seller_certificate, :successful, :contractor_ids, :product_requests_attributes, :attachments_attributes, :delivery_time_unit, :need_help, :requirements, :status, :ready, :owner_id,  :state

  attr_readonly :deal_id, :owner_id
  attr_writer :current_step
  attr_accessor :ready

  #validations
  validates_presence_of :deal_id
  validate :contractor_must_be_buyer, on: :create

  validates_presence_of :title, :duration, if: lambda {|t| current_step?('general_info')}
  validate :duration, numericality: true, if: lambda {|t| current_step?('general_info')}
  validates_presence_of :conditions_of_supply, if: lambda {|t| current_step?('conditions_of_supply')}
  validate :must_have_product_requests, if: lambda {|t| current_step?('add_product_requests')}
  validate :currency_readonly, on: :update
  validate :last_more_days, if: lambda {|t| current_step?('general_info')}

  validates_acceptance_of :ready, if: lambda {|t| current_step?('active')}

  #associations
  has_one :ns_help, dependent: :destroy

  has_many :project_contractors, as: :projectable, dependent: :destroy
  has_many :contractors, through: :project_contractors

  has_many :messages, as: :messagable, dependent: :destroy
  has_many :attachments, as: :attachable, dependent: :destroy
  has_many :notifications, as: :notifiable, dependent: :destroy

  # has_many :tender_contractors, dependent: :destroy
  # has_many :contractors, through: :tender_contractors

  has_many :product_requests, dependent: :destroy, inverse_of: :tender, order: 'created_at ASC'

  has_many :tender_responses, dependent: :destroy, inverse_of: :tender

  belongs_to :deal, dependent: :destroy
  belongs_to :owner, class_name: 'Contractor', foreign_key: 'owner_id'

#scopes
  scope :active, -> {where(state: 'active')}
  scope :archive, -> {where("state = ? OR state = ?", 'successful', 'unsuccessful')}

  scope :waiting_for_approving, -> {where(state: 'waiting')}
  scope :for_contractor, -> {active.order('created_at DESC')}
  scope :for_supplier, -> {where("state = ? OR state = ? OR state = ?", 'successful', 'unsuccessful', 'active')}
  scope :without_new, -> {where{state != 'new'}}
  accepts_nested_attributes_for :product_requests, :attachments, allow_destroy: true

#callbacks
  before_save :set_service
  before_update :update_end_date, if: :prolongation?
  before_update :remove_delayed_tasks, if: :completed?

# статусы. State machine, please!
  def need_help?
    need_help == true && waiting?
  end

  def prolongation?
    if start_at.presence
      start_at.beginning_of_day + PROLONG_AFTER.days < Time.now
    end
  end

  def current_step?(step)
    status == step || active?
  end

  def visible_for?(current_contractor)
    owner?(current_contractor) || (contractor_ids.include?(current_contractor.id) && approved?)
  end

  def owner?(current_contractor)
    owner_id == current_contractor.id
  end

#state machine
  state_machine initial: :new do
    after_transition on: [:success, :unsuccess], do: :end_project

    state :new do
      def current_state
        I18n.t('statuses.tender.new')
      end
    end
    state :form do
      def current_state
        I18n.t('statuses.tender.form')
      end
    end
    state :waiting do
      def current_state
        I18n.t('statuses.tender.waiting')
      end
    end
    state :active do
      def current_state
        I18n.t('statuses.tender.active')
      end
    end
    state :successful do
      def current_state
        I18n.t('statuses.tender.successful')
      end
    end
    state :unsuccessful do
      def current_state
        I18n.t('statuses.tender.unsuccessful')
      end
    end
  #events
    event :to_form do
      transition new: :form
    end

    event :send_to_ns do
      transition form: :waiting
    end

    event :approve do
      transition waiting: :active
    end

    event :success do
      transition active: :successful
    end

    event :unsuccess do
      transition active: :unsuccessful
    end

  #states
    state :active, :successful, :unsuccessful do
      def approved?
        true
      end
    end

    state all - [:active, :successful, :unsuccessful] do
      def approved?
        false
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

    after_transition on: :send_to_ns do |tender|
      tender.notifications.build(contractor_id: tender.owner_id).set_body(:created)
      tender.notifications.build(contractor_id: Contractor.ns.id).set_body(:created_to_myved)
    end

  end
#

# скоупы или возвраты других объетов Active Record
  def for_current_contractor(current_contractor)
    current_contractor.tenders
  end

  def answer_by(current_contractor)
    tender_responses.where(contractor_id: current_contractor.id).first
  end
#


# строковые возвраты для вьюшек
  def plural_date
    {'days' => ['день', 'дня', 'дней', 'дня']}[delivery_time_unit]
  end

  def delivery_time_view
    delivery_time.round(0) if delivery_time.presence
  end

  def title_string
    title.presence ? title : Deal.human_attribute_name(:untitled)
  end

  def message_title
    "Тендер №#{id} \'#{title_string}\'. Сделка №#{deal.id}"
  end

  def deal_link
    if status == 'active'
      "Закупка: \"#{link_to(self.try(:title) || I18n.t(:no_title), '/tenders/' + self.id.to_s)}\""
    else
      "Закупка: \"#{link_to(self.try(:title) || I18n.t(:no_title), '/tenders/' + id.to_s + '/build/' + (status || 'general_info'))}\""
    end
  end

  def supplier_status(current_contractor)
    tender_response = tender_responses.detect{|tr| tr.contractor == current_contractor}
    if tender_response.presence
      tender_response.current_state
    elsif completed?
      I18n.t('statuses.tender_response.loser')
    else
      I18n.t('statuses.tender_response.new')
    end
  end
#

#подсчеты
  def best_response(responses)
    responses.collect{|tr| tr.summ_cost}.min
  end

  def hours_left
    ((end_at.end_of_day() - Time.new)/1.hour).round
  end

  def summ_expected_cost
    pairs = product_requests.select{|pr| pr.price.presence && pr.quantity.presence}.collect{|pr| [pr.price, pr.quantity]}
    cost = 0
    pairs.each do |p|
      cost += p[0]*p[1]
    end
    cost
  end
#
# действия
  #рассмотреть возможность перевода в коллбеки или вынести в отдельный класс. Учитывать, что update бывает не только в действии update.
  def reject_all
    tender_responses.each do |tr|
      tr.lose
    end
    self.end_at = Time.now.to_date
    distribution_for_participants(:reject_all, :reject_all)
    unsuccess
    deal.unsuccess
  end

  def set_end_date
    self.start_at = Time.now
    self.end_at = duration.business_days.after(start_at)
  end

  def save_with_callbacks
    set_end_date
    project_contractors.each do |pc|
      pc.to_current
    end
    # создаем отложенные таски окончания тендера
    TenderCheckAnswersWorker.perform_at(check_answers_time, id)
    TenderEndWorker.perform_at(end_reminder_time, id)
    save

    distribution_for_participants(:approve, :approve_to_supplier)
  end

  def save_with_winner(tender_response)
    losers_ids = []
    winner_id = ''
    tender_responses.each do |tr|
      if tr.id.to_s == tender_response
        tr.win
        deal.supplier = tr.contractor
        winner_id = tr.contractor.id
      else
        tr.lose
        losers_ids << tr.contractor.id
      end
    end
    self.end_at = Time.now.to_date
    deal.save
    success

    notifications.build(contractor_id: winner_id).set_body(:win_to_winner)

    losers_ids.each do |loser_id|
      notifications.build(contractor_id: loser_id).set_body(:win_to_losers)
    end
    save
  end

  def update_prolongation_delayed_tasks
    if prolongation?
      tenderEndTime = PROLONGATION_BY.business_days.after(self.end_at).beginning_of_day

      TenderEndWorker.delete_jobs_by_tender_id(self.id)
      TenderEndWorker.perform_at(tenderEndTime, self.id)

      #resque
      # Resque.remove_delayed(TenderEnd, self.id)
      # Resque.enqueue_at(tenderEndTime , TenderEnd, self.id)
    end
  end

  def distribution_for_participants(message_method_for_one, message_method_for_all)
    # посылаем сообщение организатору
    notifications.build(contractor_id: owner.id).set_body(message_method_for_one)

    # посылаем сообщения другим участникам
    tender_contractors.each do |tc|
      notifications.build(contractor_id: tc.contractor_id).set_body(message_method_for_all)
    end
  end

  def tender_contractors
    project_contractors.not_this(owner)
  end

  def in_date_of_end
    if active?
      send_reminder_message
      TenderCloseWorker.perform_at(autoclose_time, id)
      #Resque.enqueue_at(tender.autoclose_time, TenderClose, tender_id)
    end
  end

  def autoclose
    reject_all if current?
  end

# напоминания для отложенных событий
  def send_reminder_message
    notifications.build(contractor_id: owner_id).set_body(:end_reminder)
    end_reminder
  end
  
  def send_reminder_to_participant(receiver_id)
    notifications.build(contractor_id: receiver_id).set_body(:reminder_to_participant)
  end

  def send_reminder_message_after_check_answers
    # tender_contractors.not_declined.each do |tender_contractor|
    #   unless tender_responses.select{|tr| tr.contractor_id == tender_contractor.contractor_id}.any?
    #     send_reminder_to_participant(tender_contractor.contractor_id)
    #   end
    # end
  end
#

# опции для селекторов
  def self.conditions_of_supply_options
    {'1.Группа E Отгрузка' => ['EXW'],
    '2.Группа F Основная перевозка не оплачена продавцом' => [
      'FCA',
      'FAS',
      'FOB'],
    '3.Группа C Основная перевозка оплачена продавцом' => [
      'CFR',
      'CIF',
      'CPT',
      'CIP'],
    '4.Группа D Доставка' => [
      'DAP',
      'DAT',
      'DDP']}
  end

  def self.currency_options
    ['$', '&euro;']
  end

  def self.terms_of_payment_units
   [
    ['дни', 'days']
  ]
  end

  def subject
    "#{Tender.model_name.human}: #{title}"
  end
#

# время для воркеров
  def end_reminder_time
    #считается от даты окончания тендера
    REMINDER_END_AFTER.business_days.after(end_at).beginning_of_day
  end

  def check_answers_time
    #считается от даты одобрения
    REMINDER_ANSWERS_AFTER.business_days.from_now.beginning_of_day
  end

  def autoclose_time
    #считается от end_reminder_time
    AUTOCLOSE_AFTER.business_days.from_now.beginning_of_day
  end

  private

  #callbacks

  def end_project
    project_contractors.not_ended.each do |pc|
      pc.update_attributes(end_at: Time.now)
    end
  end

  def remove_delayed_tasks
    TenderCheckAnswersWorker.delete_jobs_by_tender_id(id)
    TenderCloseWorker.delete_jobs_by_tender_id(id)
    TenderEndWorker.delete_jobs_by_tender_id(id)

    #resque
    # Resque.remove_delayed(TenderEnd, self.id)
    # Resque.remove_delayed(TenderCheckAnswers, self.id)
    # Resque.remove_delayed(TenderClose, self.id)
  end

  def update_end_date
    self.end_at = NEW_END_DATE_BY.business_days.after(self.end_at)
  end

  def set_service
    self.service = '' unless ['ODM Service', 'OEM Service'].include?(service)
  end

#validations

  #отличается от остальных, нельзя выносить
  def contractor_must_be_buyer
    if !owner.buyer?
      errors.add :contractor_id, 'must be buyer'
    end
  end

  def must_have_product_requests
    if product_requests.empty?
      errors.add :product_requests, 'amount must be greater than 0'
    end
  end

  def last_more_days
    if need_help == true && duration < 5
      errors.add :duration, 'должна быть больше 5 дней, если вы хотите воспользоваться помощью myVED'
    end
  end

  def currency_readonly
    if currency_changed? && approved?
      errors.add :currency, 'не может быть изменена'
    end
  end

  def update_after_completion
    if completed?
      errors[:base] << 'не может быть изменен после завершения'
    end
  end
#
end
