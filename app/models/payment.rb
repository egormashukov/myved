#encoding: utf-8
class Payment < ActiveRecord::Base
  attr_accessible :comment, :contractor_id, :invoice, :invoice_numb, :invoice_on, :paid_on, :paidable_id, :paidable_type, :purpose, :state, :sum, :type, :to_state, :currency

  mount_uploader :invoice, PaymentsUploader
  validates :contractor_id, presence: true
  validates :sum, numericality: true

  scope :for_contractor, -> { where(state: ['sent', 'paid']) }
  scope :waiting, -> { where(state: 'new') }

  attr_accessor :to_state

  belongs_to :paidable, polymorphic: true
  belongs_to :contractor

  after_update :set_state
  has_many :notifications, as: :notifiable, dependent: :destroy

  def self.currency_options
    ['руб.', '$', '&euro;']
  end

  def set_state
    self.try(to_state) if to_state.present?
  end

  def subject
    paidable.try(:subject) || 'Информация по счёту'
  end

  def mailer_class
    (paidable.respond_to?(:type) && paidable.type) || paidable.class.name
  end

  def human_state
    I18n.t("statuses.payments.#{state}")
  end
end
