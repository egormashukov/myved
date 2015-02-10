class ContractorMailer < Devise::Mailer
  default from: "\"myVED\" <admin@myved.com>", css: 'email'
  layout "message_mailer"

  def confirmation_instructions(record, token)
    @contractor = Contractor.ns
    @mail_title = Message.greetings_message(:title, record)
    @mail_body = Message.greetings_message(:body, record)

    super
  end

  def reset_password_instructions(record, token)
    @contractor = Contractor.ns
    super
  end

  def unlock_instructions(record, token)
    @contractor = Contractor.ns
    super
  end
end
