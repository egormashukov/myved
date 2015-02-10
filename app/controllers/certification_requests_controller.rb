# encoding: utf-8

class CertificationRequestsController < ApplicationController
  before_filter :check_contractor, except: [:new, :create]
  before_filter :check_admin, only: [:pay, :next_step]

  def pay
    @ved_request.update_attributes(paid: true)

    Message.new(receiver_id: @ved_request.contractor_id, sender_id: Contractor.ns.id).certification_paid(@ved_request)
    redirect_to :back
  end

  def new
    @certification_request = CertificationRequest.new
    @certification_request.ved_messages.presence || @certification_request.ved_messages.build
  end

  def create
    @certification_request = CertificationRequest.new(params[:certification_request])
    @certification_request.contractor = current_contractor
    @certification_request.ved_messages.first.contractor = current_contractor

    if @certification_request.save
      @certification_request.to_next_step
      redirect_to @certification_request, notice: I18n.t("notice.certification_request.sent_to_myved")
    else
      render :new
    end
  end

  def update
    @ved_request.update_attributes(params[:certification_request])
    redirect_to :back
  end

  def next_step
    @ved_request.to_next_step
    redirect_to :back, notice: "вы перешли на следующий шаг"
  end

  def show
    @ved_message = VedMessage.new
  end

  def toggle_archived
    @ved_request.toggle("archived")
    @ved_request.save
    redirect_to :back
  end

  def destroy
    @ved_request.destroy
    redirect_to :back, notice: 'запрос успешно удален'
  end

  private

  def check_admin
    @ved_request = CertificationRequest.find(params[:id])
    unless current_contractor.ns?
      redirect_to root_path, notice: I18n.t(:havent_access)
    end
  end

  def check_contractor
    @ved_request = CertificationRequest.find(params[:id])
    unless @ved_request.contractor == current_contractor || current_contractor.ns?
      redirect_to root_path, notice: I18n.t(:havent_access)
    end
  end
end