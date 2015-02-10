# encoding: utf-8

class SeaFreightExecutionStatusesController < ApplicationController
  before_filter :authenticate_contractor!
  before_filter :check_contractor

  def update
    @sea_freight_execution_status.update_attributes(params[:sea_freight_execution_status])
    redirect_to :back
  end

  private

  def check_contractor
    @sea_freight_execution_status = SeaFreightExecutionStatus.find(params[:id])
    unless current_contractor.ns? || @sea_freight_execution_status.winner?(current_contractor)
      redirect_to root_path, notice: I18n.t(:havent_access)
    end
  end
end
