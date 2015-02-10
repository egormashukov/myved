# encoding: utf-8

class SeaFreights::DeclineController < ApplicationController
  before_filter :authenticate_contractor!
  before_filter :check_owner

  def new
    @sea_freight_decline = SeaFreight::Decline.new

  end

  def create
    @sea_freight_decline = SeaFreight::Decline.find(params[:sea_freight_id])
    if @sea_freight_decline.update_attributes(params[:sea_freight_decline])
      @sea_freight.reject_all
      @sea_freight.notifications.build(contractor_id: @sea_freight.contractor_id).set_body(:reject_all)

      @sea_freight.sea_freight_responses.activated.each do |sea_freight_response|
        @sea_freight.notifications.build(contractor_id: sea_freight_response.contractor_id).set_body(:reject_all)
      end

      redirect_to sea_freight_path(@sea_freight_decline)
    else
      render :new
    end
  end

  private

  def check_owner
    @sea_freight = SeaFreight.find(params[:sea_freight_id]).decorate
    unless @sea_freight.owner?(current_contractor) || current_contractor.ns?
      redirect_to @sea_freight, notice: 'вы не имеете доступа к этой информации'
    end
  end
end
