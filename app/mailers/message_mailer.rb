# encoding: utf-8

class MessageMailer < ActionMailer::Base
  default from: "\"myVED\" <admin@myved.com>", css: 'email'
  include ActionView::Helpers::TextHelper

  def new_message(message)
    @message = message
    @sender = message.sender
    @message_body = message.body

    mail(to: message.receiver.email, subject: strip_tags(message.messagable.try(:subject)).presence || "myVED. Сообщение от #{message.sender.title}")
  end

  def send_invitations(emails, contractor)
    emails = emails.gsub(/\s+/, "").split(",").reject{|e| (e=~/.+@.+\..+/i).nil?}

    @mail_title = Message.invitation_from_contractor(contractor, :title)
    @mail_body = Message.invitation_from_contractor(contractor, :body)
    @contractor = contractor
    mail(to: emails.join("; "), subject: strip_tags(@mail_title).presence)
  end

  def send_invite_from_myved(email, tender)
    @tender = tender
    @contractor = Contractor.ns
    @title = "Примите участие в новых торгах #{@tender.title}"
    mail(to: email, subject: @title)
  end
end
