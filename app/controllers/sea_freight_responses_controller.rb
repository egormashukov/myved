# encoding: utf-8
class SeaFreightResponsesController < ApplicationController
  before_filter :authenticate_contractor!
  before_filter :set_sea_freight, except: :destroy
  before_filter :check_owner


  def edit
  end

  def create
    @sea_freight_response = @sea_freight.sea_freight_responses.create(params[:sea_freight_response])

    if @sea_freight_response.valid?
      @sea_freight_response.approve
      @sea_freight.send_best_notifications(@sea_freight_response)

      redirect_to @sea_freight, notice: I18n.t("notice.sea_freight_response.added")
    else
      render 'new'
    end
  end

  def update
    @sea_freight_response = SeaFreightResponse.find(params[:id])
    @sea_freight_response.assign_attributes(params[:sea_freight_response])
    if @sea_freight_response.increment_updated_count && @sea_freight_response.valid?
      @sea_freight_response.approve if @sea_freight_response.new?
      @sea_freight_response.save
      @sea_freight.send_best_notifications(@sea_freight_response)
      redirect_to @sea_freight, notice: I18n.t("notice.sea_freight_response.update")
    else
      render "edit"
    end

  end

  def destroy
    @sea_freight_response.destroy
    redirect_to :back
  end

private

  def set_sea_freight
    @sea_freight = SeaFreight.find(params[:sea_freight_id]).decorate
    @sea_freight_responses = @sea_freight.sea_freight_responses.activated.by_total
    @best_response = @sea_freight.winner.try(:decorate).presence || @sea_freight_responses.best.try(:decorate)
  end

  def check_owner
    @sea_freight_response = SeaFreightResponse.find(params[:id])
    unless current_contractor.ns? || @sea_freight_response.owner?(current_contractor)
      redirect_to @sea_freight, notice: I18n.t(:havent_access)
    end
  end

end
