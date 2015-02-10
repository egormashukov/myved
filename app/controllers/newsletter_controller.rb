# encoding: utf-8
class NewsletterController < ApplicationController
  def create
    gb = Gibbon::API.new('4f4088d8d6c985015d525273794d9293-us8', { timeout: 5 })
    begin
      gb.lists.subscribe({ id: '1a734893fb', email: { email: params[:email] }, merge_vars: { :FNAME => 'First Name', :LNAME => 'Last Name' }, double_optin: false })
      @message = 'подписка на рассылку успешно выполнена'
    rescue Gibbon::MailChimpError => e
      @message = 'Подписка на рассылку не удалась. Вы уже подписаны'
    end
    respond_to do |format|
      format.js { render 'create.js.erb' }
    end
  end
end
