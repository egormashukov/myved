#encoding: utf-8

class Notification < ActiveRecord::Base
  attr_accessible :body, :contractor_id, :notifiable_id, :notifiable_type, :read

  belongs_to :notifiable, polymorphic: true
  belongs_to :contractor

  scope :by_created, -> { order('created_at DESC') }
  scope :not_read, -> { where(read: false) }

  after_create :send_email

  def title
    notifiable.subject
  end

  def set_body(notice_body, obj = '')
    b = notifiable.try(:class).try(:name)
    #klass = [NotificationSeaFreight, NotificationPayment].detect{|c| "Notification#{b}"}
    klass = "Notification#{b}".constantize
    self.body = klass.new(self, obj).try(notice_body)
    save
  end

  def send_email
    NotificationMailer.send_notification(self).deliver
  end

  def owner?(current_contractor)
    contractor == current_contractor
  end
end