# encoding: utf-8

class NsHelp < ActiveRecord::Base
  attr_accessible :context, :contractor_id, :tender_id, :deal_id, :processed, :emails
  attr_accessor :email
  attr_readonly :contractor_id
  
  belongs_to :contractor
  belongs_to :deal
  belongs_to :tender
  scope :not_processed, -> {where(processed: false)}
  after_create :send_message

  def processed_string
    processed? ? 'обработан' : 'не обработан'
  end

  def send_message
    Message.new(receiver_id: Contractor.ns.id, sender_id: Contractor.ns.id).ns_help(self)
    Message.new(receiver_id: Contractor.china.id, sender_id: Contractor.ns.id).ns_help(self)
  end
end
