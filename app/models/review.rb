# encoding: utf-8
class Review < ActiveRecord::Base
  attr_accessible :body, :contractor_id
  validates_presence_of :body, :contractor_id
  belongs_to :contractor
  after_create :send_message

private
  def send_message
    Message.create(title: "Отзыв от #{contractor.title}", body: body, receiver_id: Contractor.ns.id, sender_id: contractor_id)
  end

end
