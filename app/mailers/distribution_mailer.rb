# encoding: utf-8
class DistributionMailer < Devise::Mailer
  default from: "\"myVED\" <admin@myved.com>", css: 'distribution'

  def send_invitations(emails)
    emails = emails.gsub(/\s+/, "").split(",").reject{|e| (e=~/.+@.+\..+/i).nil?}
    mail(to: emails.join("; "), subject: 'Приглашаем на тестирование профессиональной площадки в области ВЭД')
  end


end
