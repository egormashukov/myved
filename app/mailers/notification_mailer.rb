# encoding: utf-8

class NotificationMailer < ActionMailer::Base
  default from: "\"myVED\" <admin@myved.com>", css: 'email', layout: "notification_mailer"
  include ActionView::Helpers::TextHelper

  def send_notification(notification)
    @subject = notification.title
    receivers_emails = notification.contractor.email_lists.for_notification(notification)
    @body = notification.body
    @sender = Contractor.ns

    mail(to: receivers_emails, subject: @subject.presence)
  end
end
