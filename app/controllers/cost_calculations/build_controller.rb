# encoding: utf-8

class CostCalculations::BuildController < ApplicationController
  include Wicked::Wizard

  before_filter :authenticate_contractor!
  before_filter :check_owner, except: :building

  before_filter :check_new, except: :building

  steps :general_info, :products, :final

  def show
    @step = step
    @steps = steps.size
    render_wizard
  end

  def update
    params[:cost_calculation][:status] = step.to_s
    if step == steps.last
      params[:cost_calculation][:status] = 'active'
    end
    @cost_calculation.assign_attributes(params[:cost_calculation])
    if @cost_calculation.save
      if step == steps.last
        @cost_calculation.send_to_ns
        redirect_to cost_calculation_execution_path(@cost_calculation.cost_calculation_execution, autorun: true)
      else
        @cost_calculation.to_form
        render_wizard @cost_calculation
      end
    else
      render_wizard @cost_calculation
    end
  end

  def building
    if params[:deal_id].presence
      @deal = Deal.find(params[:deal_id])
    else
      @deal = current_contractor.deals.create
    end
    @cost_calculation = @deal.build_cost_calculation(contractor_id: current_contractor.id)
    if @cost_calculation.save
      @deal.to_cost_calculation
      if @cost_calculation.has_tender?
        @cost_calculation.dublicate_products(@deal.tender.tender_responses.winner, current_contractor)
      end
      redirect_to wizard_path(steps.first, cost_calculation_id: @cost_calculation.id, window: params[:window]), notice: I18n.t('notice.cost_calculation.sent_to_myved')
    else
      redirect_to :back, notice: 'функция недоступна'
    end
  end

  private

  def check_owner
    @cost_calculation = CostCalculation.find(params[:cost_calculation_id])
    @deal = @cost_calculation.deal
    if @cost_calculation.has_tender?
      @tender_response = @deal.tender.tender_responses.where(contractor_id: @deal.supplier_id).first
    end
    unless @cost_calculation.owner?(current_contractor)
      redirect_to @cost_calculation, notice: 'вы не имеете доступа к этой информации'
    end
  end

  def check_new
    if @cost_calculation.active?
      redirect_to @cost_calculation
    end
  end
end
