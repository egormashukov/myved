# encoding: utf-8

class SeaFreights::ReportController < ApplicationController
  before_filter :authenticate_contractor!
  before_filter :check_owner

  def index
    load_best_response
    respond_to do |format|
      format.pdf do
        render text: AgreementPdf.new(@sea_freight, @best_response).render
      end
    end
  end

  private

  def load_best_response
    @best_response = @sea_freight.winner.try(:decorate).presence
  end

  def check_owner
    @sea_freight = SeaFreight.find(params[:sea_freight_id]).decorate
    unless (@sea_freight.owner?(current_contractor) || current_contractor.ns? || current_contractor == @sea_freight.winner.try(:contractor)) && @sea_freight.completed?
      redirect_to @sea_freight, notice: 'вы не имеете доступа к этой информации'
    end
  end
end
