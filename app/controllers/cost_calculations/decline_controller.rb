# encoding: utf-8

class CostCalculations::DeclineController < ApplicationController
  before_filter :authenticate_contractor!
  before_filter :check_owner

  def new
    @cost_calculation_decline = CostCalculation::Decline.new
  end

  def create
    @cost_calculation_decline = CostCalculation::Decline.find(params[:cost_calculation_id])
    if @cost_calculation_decline.update_attributes(params[:cost_calculation_decline])
      @cost_calculation_decline.decline
      redirect_to cost_calculation_path(@cost_calculation_decline)
    else
      render :new
    end
  end

  private

  def check_owner
    @cost_calculation = CostCalculation.find(params[:cost_calculation_id])
    unless @cost_calculation.owner?(current_contractor) || current_contractor.ns?
      redirect_to @cost_calculation, notice: 'вы не имеете доступа к этой информации'
    end
  end
end
