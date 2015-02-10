# encoding: utf-8

#coding: utf-8
class Admin::MessagesController < Admin::ApplicationController
  before_filter :china?
  
  def create
    if @messagable
      @message = @messagable.messages.build(params[:message])
    else
      @message = Message.new(params[:message])
    end
    if user_signed_in?
      @message.sender = @admin_contractor
    else
      @message.sender = current_contractor
    end
    if @message.save
      redirect_to :back, notice: 'Сообщение отправлено'
    else
      redirect_to :back, notice: 'Сообщение невозможно отправить'
    end
  end

end