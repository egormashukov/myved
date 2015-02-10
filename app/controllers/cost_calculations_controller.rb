# encoding: utf-8

class CostCalculationsController < ApplicationController
  before_filter :authenticate_contractor!
  before_filter :check_owner, only: [:send_to_ns, :show, :report, :accept, :decline, :refusal_cause]
  before_filter :check_admin, only: [:edit, :update]

  def refusal_cause
  end

  def accept
    @cost_calculation.update_attributes(accepted: true)
    @cost_calculation.accept

    redirect_to :back, notice: I18n.t('notifications.cost_calculation_acceptance_to_contractor')
  end

  def decline
    @cost_calculation.update_attributes(accepted: false, failure_cause: params[:cost_calculation][:failure_cause])
    @cost_calculation.decline
    redirect_to @cost_calculation.cost_calculation_execution, notice: 'Благодарим Вас за ответ'
  end
  # def new
  #   if params[:deal_id].presence
  #     @deal = Deal.find(params[:deal_id])
  #     @cost_calculation = @deal.build_cost_calculation
  #     @pth = [@deal, @cost_calculation]
  #     @tender_response = @deal.tender.tender_responses.winner
  #   else
  #     @cost_calculation = CostCalculation.new
  #     @pth = @cost_calculation
  #   end
  #   @step = 'first'
  # end

  def show
    redirect_to @cost_calculation.cost_calculation_execution
  end

  def report
    if @cost_calculation.has_tender?
      @tender = @cost_calculation.tender
    end
  end

  # def create
  #   if params[:deal_id].presence
  #     @deal = Deal.find(params[:deal_id])
  #     @deal.to_cost_calculation
  #     @cost_calculation = @deal.build_cost_calculation(params[:cost_calculation])
  #     @pth = [@deal, @cost_calculation]
  #     @tender_response = @deal.tender.tender_responses.winner
  #   else
  #     @cost_calculation = CostCalculation.new(params[:cost_calculation])
  #     if @cost_calculation.valid?
  #       @cost_calculation.deal = Deal.create_for_calculation(current_contractor)
  #     end
  #     @pth = @cost_calculation
  #   end
  #   @step = 'first'
  #   @cost_calculation.contractor = current_contractor
  #   if @cost_calculation.valid? && @cost_calculation.save_with_supplier_products
  #     redirect_to @cost_calculation
  #   else
  #     render :new
  #   end
  # end

  def edit
    @deal = @cost_calculation.deal
    if @cost_calculation.has_tender?
      @tender = @cost_calculation.tender
      @tender_response = @tender.tender_responses.where(contractor_id: @deal.supplier_id).first
    end
  end

  def update
    @cost_calculation.assign_attributes(params[:cost_calculation])

    if @cost_calculation.save
      redirect_to @cost_calculation
    else
      render :edit
    end
  end

private

  def check_owner
    @cost_calculation = CostCalculation.find(params[:id])
    unless @cost_calculation.owner?(current_contractor) || current_contractor.ns?
      redirect_to deals_path, notice: I18n.t(:havent_access)
    end
  end

  def check_admin
    @cost_calculation = CostCalculation.find(params[:id])
    unless current_contractor.ns?
      redirect_to deals_path, notice: I18n.t(:havent_access)
    end
  end
end
