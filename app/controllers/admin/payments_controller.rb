#coding: utf-8
class Admin::PaymentsController < Admin::ApplicationController
  helper_method :sort_column, :sort_direction

  def index
    @payments = Payment.order(sort_column + " " + sort_direction)
  end
  
  def new
    @payment = Payment.new
    render 'edit'
  end
  
  def edit
    @payment = Payment.find(params[:id])
  end
  
  def create
    @payment = Payment.new(params[:payment])
    if @payment.save
      redirect_to admin_payments_path, :notice => "#{Payment.model_name.human} #{t 'flash.notice.was_added'}"
    else
      render 'edit'
    end
  end

  def update
    @payment = Payment.find(params[:id])
    if @payment.update_attributes(params[:payment])
      redirect_to admin_payments_path, :notice => "#{Payment.model_name.human} #{t 'flash.notice.was_updated'}"
    else
      render 'edit'
    end
  end
  
  def destroy
    @payment = Payment.find(params[:id])
    @payment.destroy
    redirect_to admin_payments_path, :alert => "#{Payment.model_name.human} #{t 'flash.notice.was_deleted'}"
  end

  private

  def sort_column
    Payment.column_names.include?(params[:sort]) ? params[:sort] : 'created_at'
  end
  
  def sort_direction
    %w[asc desc].include?(params[:direction]) ? params[:direction] : "asc"
  end  
end