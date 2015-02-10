# encoding: utf-8

class SeaFreightsController < ApplicationController
  before_filter :authenticate_contractor!
  before_filter :check_owner, except: :show
  before_filter :check_show, only: :show
  before_filter :check_authorized, only: [:set_winner, :reject_all]

  def edit
    @sea_freight = @sea_freight.decorate
  end

  def update
    if @sea_freight.update_attributes(params[:sea_freight])
      redirect_to @sea_freight
    else
      render :edit
    end
  end

  def show
    set_messages
    @sea_freight = @sea_freight.decorate
    @sea_freight_responses = @sea_freight.sea_freight_responses.activated_with_messages.by_total
    set_best
    set_ved_contractor_responses
    @sea_freight_responses = @sea_freight_responses.decorate
    set_offline_offer
  end

  def set_ved_contractor_responses
    if current_contractor.ved_contractor?
      @sea_freight_responses = @sea_freight.sea_freight_responses.by_total.where(contractor_id: current_contractor.id)
      @current_response = @sea_freight.sea_freight_responses.where(contractor_id: current_contractor.id).first.decorate
    end
  end

  def set_winner
    # вынести с отдельный класс
    @sea_freight_response = SeaFreightResponse.find(params[:sea_freight_response_id])
    @sea_freight.end_date = Time.now
    @sea_freight.winner = @sea_freight_response

    @sea_freight.sea_freight_responses.each do |rp|
      rp.lose unless rp == @sea_freight_response
    end
    @sea_freight_response.win

    @sea_freight.set_winner
    @sea_freight.save

    @sea_freight_execution = @sea_freight.try("build_sea_freight_execution_#{@sea_freight_response.category}".to_sym)
    @sea_freight_execution.contractor_id = current_contractor.id
    @sea_freight_execution.save

    @sea_freight.notifications.build(contractor_id: @sea_freight.contractor_id).set_body(:set_winner)
    @sea_freight.notifications.build(contractor_id: @sea_freight.winner_contactor.id).set_body(:set_winner_to_winner)
    @sea_freight.notifications.build(contractor_id: Contractor.ns.id).set_body(:set_winner_to_myved)

    @sea_freight.sea_freight_responses.activated.each do |sea_freight_response|
      @sea_freight.notifications.build(contractor_id: sea_freight_response.contractor_id).set_body(:set_winner_to_loosers) unless sea_freight_response == @sea_freight_response
    end

    redirect_to sea_freight_execution_path(@sea_freight_execution)
  end

  private

  def set_offline_offer
    @offline_offer = @sea_freight.offline_offer.presence || @sea_freight.build_offline_offer
  end

  def set_messages
    @messages = @sea_freight.messages.for_current_contractor(current_contractor.id).order(:created_at)
  end

  def set_best
    @best_response = @sea_freight.winner.try(:decorate).presence || @sea_freight_responses.best.try(:decorate)
  end

  def check_show
    @sea_freight = SeaFreight.includes(:sea_freight_responses).find(params[:id])
    unless @sea_freight.owner?(current_contractor) || current_contractor.ns? || @sea_freight.can_response?(current_contractor.id)
      redirect_to root_path, notice: I18n.t(:havent_access)
    end
  end

  def check_owner
    @sea_freight = SeaFreight.includes(:sea_freight_responses).find(params[:id])
    unless @sea_freight.owner?(current_contractor) || current_contractor.ns?
      redirect_to root_path, notice: I18n.t(:havent_access)
    end
  end

  def check_authorized
    unless current_contractor.authorized?
      redirect_to edit_contractor_registration_path, notice: I18n.t(:need_authorize)
    end
  end
end
