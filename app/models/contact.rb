class Contact < ActiveRecord::Base
  attr_accessible :contractor_contact_id, :contractor_id, :approved, :invitation_cod
  attr_readonly :contractor_id, :contractor_contact_id
  attr_accessor :invitation_cod

  validates_presence_of :contractor_contact_id, :contractor_id

  scope :approved, -> {where(approved: true)}
  scope :not_approved, -> {where(approved: false)}
  
  has_many :notifications, as: :notifiable, dependent: :destroy

  before_create :check_uniqueness
  after_create :send_messages

  def is_current_user?(current_contractor_id)
    if [self.contractor_id, self.contractor_contact_id].include?(current_contractor_id)
      true
    else
      false
    end
  end

  def second_id(current_contractor)
    (contractor_contact_id == current_contractor.id) ? contractor_id : contractor_contact_id
  end

  def subject
    'New contact'
  end

private

  def send_messages
    notifications.build(contractor_id: contractor_contact_id).set_body(:created)
  end

  def check_uniqueness
    if Contact.where('contractor_id = ? AND contractor_contact_id = ?', contractor_id, contractor_contact_id).any? || Contact.where('contractor_contact_id = ? AND contractor_id = ?', contractor_id, contractor_contact_id).any?
      false
    end
  end

end
