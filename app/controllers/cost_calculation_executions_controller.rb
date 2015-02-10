# encoding: utf-8

class CostCalculationExecutionsController < ApplicationController
  before_filter :check_contractor, except: [:new, :create]

  def update
    @ved_request.update_attributes(params[:cost_calculation_execution])
    redirect_to :back
  end

  def next_step
    @ved_request.to_next_step
    redirect_to :back, notice: 'вы перешли на следующий шаг'
  end

  def show
    @cost_calculation = @ved_request.vedable
    @ved_message = VedMessage.new
  end

  private

  def check_contractor
    @ved_request = CostCalculationExecution.find(params[:id]).decorate
    unless @ved_request.contractor == current_contractor || current_contractor.ns?
      redirect_to root_path, notice: I18n.t(:havent_access)
    end
  end
end