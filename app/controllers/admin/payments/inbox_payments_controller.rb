# coding: utf-8
# inbox payments controller
class Admin::Payments::InboxPaymentsController < Admin::ApplicationController
  def new
    build_payment
    render 'edit'
  end

  def edit
    load_payment
    build_payment
  end

  def create
    build_payment
    save_payment || render(:edit)
  end

  def update
    load_payment
    build_payment
    save_payment || render(:edit)
  end

  private

  def payments_scope
    InboxPayment.scoped
  end

  def load_payment
    @payment ||= payments_scope.find(params[:id])
  end

  def build_payment
    @payment ||= payments_scope.build
    @payment.attributes = payment_params
  end

  def save_payment
    redirect_to [:admin, :payments], notice: "#{InboxPayment.model_name.human} #{t 'flash.notice.was_updated'}" if @payment.save
  end

  def payment_params
    return {} unless params[:inbox_payment].present?
    params[:inbox_payment]
  end
end
