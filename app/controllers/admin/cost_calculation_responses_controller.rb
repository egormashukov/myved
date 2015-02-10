#coding: utf-8
class Admin::CostCalculationResponsesController < Admin::ApplicationController
  helper_method :sort_column, :sort_direction
  before_filter :get_cost_calculation, only: [:new, :create]
  before_filter :china?
  
  def new
    @cost_calculation_response = @cost_calculation.build_cost_calculation_response
    @pth = [:admin, @cost_calculation,@cost_calculation_response]
    render 'edit'
  end
  
  def edit
    @cost_calculation_response = CostCalculationResponse.find(params[:id])
    @cost_calculation = @cost_calculation_response.cost_calculation
    @pth = [:admin, @cost_calculation_response]
  end
  
  def create
    @cost_calculation_response = @cost_calculation.build_cost_calculation_response(params[:cost_calculation_response])
    @pth = [:admin, @cost_calculation, @cost_calculation_response]
    if @cost_calculation_response.save
      notice = "#{CostCalculationResponse.model_name.human} #{t 'flash.notice.was_added'}"
      if params[:apply].presence
        redirect_to [:edit, :admin, @cost_calculation_response], :notice => notice
      else
        redirect_to [:admin, :cost_calculations], :notice => notice
      end
    else
      render 'edit'
    end
  end

  def update
    @cost_calculation_response = CostCalculationResponse.find(params[:id])
    @cost_calculation = @cost_calculation_response.cost_calculation
    @pth = [:admin, @cost_calculation_response]
    if @cost_calculation_response.update_attributes(params[:cost_calculation_response])
      notice = "#{CostCalculationResponse.model_name.human} #{t 'flash.notice.was_updated'}"
      if params[:apply].presence
        redirect_to [:edit, :admin, @cost_calculation_response], :notice => notice
      else
        redirect_to [:admin, :cost_calculations], :notice => notice
      end
    else
      render 'edit'
    end
  end
  
  def destroy
    @cost_calculation_response = CostCalculationResponse.find(params[:id])
    @cost_calculation_response.destroy
    redirect_to [:edit, :admin, @cost_calculation], :alert => "#{CostCalculationResponse.model_name.human} #{t 'flash.notice.was_deleted'}"
  end

  private
  def china?
    if current_user.china?
      redirect_to [:admin, :ns_helps]
    end
  end
  def get_cost_calculation
    @cost_calculation = CostCalculation.find(params[:cost_calculation_id])
  end

  def sort_column
    CostCalculationResponse.column_names.include?(params[:sort]) ? params[:sort] : 'created_at'
  end
  
  def sort_direction
    %w[asc desc].include?(params[:direction]) ? params[:direction] : "DESC"
  end  
end