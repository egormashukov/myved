# encoding: utf-8

class SeaFreightExecutionsController < ApplicationController
  before_filter :authenticate_contractor!
  before_filter :check_contractor, except: [:new, :create]
  before_filter :check_admin, only: :pay

  def pay
    @ved_request.update_attributes(paid: true)

    Message.new(receiver_id: @ved_request.contractor_id, sender_id: Contractor.ns.id).certification_paid(@ved_request)
    redirect_to :back
  end

  def update
    @ved_request.update_attributes(params[:sea_freight_execution])
    redirect_to :back
  end

  def next_step
    @ved_request.to_next_step
    redirect_to :back, notice: "вы перешли на следующий шаг"
  end

  def show
    @ved_message = VedMessage.new
    @sea_freight = @ved_request.vedable.decorate
    @best_response = @sea_freight.winner.try(:decorate).presence
    @sea_freight_execution_status = @ved_request.sea_freight_execution_status
    @sea_freight.sea_freight_execution.general_rule = GeneralRule.by_created.last
    @sea_freight.sea_freight_execution.forwarding_service = ForwardingService.by_created.last
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
    @ved_request = VedRequest.find(params[:id]).decorate
    unless current_contractor.ns?
      redirect_to root_path, notice: I18n.t(:havent_access)
    end
  end

  def check_contractor
    @ved_request = VedRequest.find(params[:id]).decorate
    unless @ved_request.vedable.contractor == current_contractor || current_contractor.ns? || @ved_request.vedable.winner.try(:contractor) == current_contractor
      redirect_to root_path, notice: I18n.t(:havent_access)
    end
  end
end