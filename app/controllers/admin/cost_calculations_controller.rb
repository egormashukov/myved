#coding: utf-8
class Admin::CostCalculationsController < Admin::ApplicationController
  helper_method :sort_column, :sort_direction

  def index
    @cost_calculations = CostCalculation.admin.order(sort_column + ' ' + sort_direction)
  end

  def new
    @cost_calculation = CostCalculation.new
    render 'edit'
  end

  def edit
    @cost_calculation = CostCalculation.find(params[:id])
  end

  def create
    @cost_calculation = CostCalculation.new(params[:cost_calculation])
    if @cost_calculation.save
      notice = "#{CostCalculation.model_name.human} #{t 'flash.notice.was_added'}"
      if params[:apply].presence
        redirect_to [:edit, :admin, @cost_calculation], :notice => notice
      else
        redirect_to [:admin, :cost_calculations], :notice => notice
      end
    else
      render 'edit'
    end
  end

  def update
    @cost_calculation = CostCalculation.find(params[:id])
    if @cost_calculation.update_attributes(params[:cost_calculation])
      notice = "#{CostCalculation.model_name.human} #{t 'flash.notice.was_updated'}"
      if params[:apply].presence
        redirect_to [:edit, :admin, @cost_calculation], :notice => notice
      else
        redirect_to [:admin, :cost_calculations], :notice => notice
      end
    else
      render 'edit'
    end
  end

  def destroy
    @cost_calculation = CostCalculation.find(params[:id])
    @cost_calculation.destroy
    redirect_to admin_cost_calculations_path, :alert => "#{CostCalculation.model_name.human} #{t 'flash.notice.was_deleted'}"
  end

  private

  def sort_column
    CostCalculation.column_names.include?(params[:sort]) ? params[:sort] : 'created_at'
  end

  def sort_direction
    %w[asc desc].include?(params[:direction]) ? params[:direction] : "DESC"
  end
end
