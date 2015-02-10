# encoding: utf-8

class VedMessage < ActiveRecord::Base
  attr_accessible :body, :title, :ved_request_id, :attachments_attributes, :step, :contractor_id
  has_many :attachments, as: :attachable, dependent: :destroy

  belongs_to :ved_request
  belongs_to :contractor

  validates_presence_of :contractor_id
  validates_presence_of :title#, if: :first_message?

  accepts_nested_attributes_for :attachments

  scope :by_state, ->(state) { where(step: state).order(:created_at) }

  before_create :set_step
  after_create :send_messages

  def recievers_list
    ved_request.type.constantize.find(ved_request_id).receivers(contractor)
  end

  private

  def first_message?
    !ved_request.try(:ved_messages).presence
  end

  def set_step
    self.step = ved_request.state
  end

  def send_messages
    VedRequestMailer.send_message(self).deliver
  end
end
