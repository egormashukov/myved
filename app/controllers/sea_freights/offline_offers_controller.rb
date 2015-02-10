class SeaFreights::OfflineOffersController < ApplicationController
  before_filter :set_sea_freight


  def create
    @offline_offer = @sea_freight.build_offline_offer(params[:sea_freight_offline_offer])
    if @offline_offer.save
      redirect_to @sea_freight
    else
      render :edit
    end
  end

  def update
    @offline_offer = @sea_freight.offline_offer
    if @offline_offer.update_attributes(params[:sea_freight_offline_offer])
      redirect_to @sea_freight
    else
      render :edit
    end
  end

  def edit
    @offline_offer = @sea_freight.offline_offer
  end

  def set_sea_freight
    @sea_freight = SeaFreight.find(params[:sea_freight_id])
    unless @sea_freight.owner?(current_contractor) || current_contractor.ns?
      redirect_to root_path, notice: I18n.t(:havent_access)
    end
  end

end
