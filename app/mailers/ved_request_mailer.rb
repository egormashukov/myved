# encoding: utf-8
class VedRequestMailer < Devise::Mailer
  default from: "\"myVED\" <admin@myved.com>", css: 'email'
  layout 'message_mailer'

  def send_message(ved_message, subj = nil)
    @ved_message = ved_message
    @ved_request = ved_message.ved_request
    @sender = Contractor.ns
    @message_title = @ved_message.title
    @message_body = @ved_message.body
    subj ||= ved_message.ved_request.mail_subject

    receivers_list = ved_message.recievers_list.collect{ |r| r.email_lists.for_ved_request(ved_message.ved_request) }.flatten

    mail(bcc: receivers_list, subject: "\"#{subj}\"")
  end

  def next_step(ved_request, receivers)
    @ved_request = ved_request
    @sender = Contractor.ns
    receivers_list = receivers.collect{ |r| r.email_lists.for_ved_request(ved_request) }.flatten

    mail(bcc: receivers_list, subject: ved_request.mail_subject)
  end
end
