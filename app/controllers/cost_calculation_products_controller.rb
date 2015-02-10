# encoding: utf-8

class CostCalculationProductsController < ApplicationController
  before_filter :get_cost_calculation_product, except: [:create, :new]
  before_filter :get_cost_calculation

  def new
    @step = @cost_calculation.status
    @cost_calculation_product = @cost_calculation.cost_calculation_products.build
  end

  def create
    @cost_calculation_product = @cost_calculation.cost_calculation_products.build(params[:cost_calculation_product])
    @step = @cost_calculation.status
    if @cost_calculation_product.valid? && @cost_calculation_product.save_with_supplier_products
      redirect_to cost_calculation_build_path(@cost_calculation, 'products')
    else
      render 'new'
    end
  end

  def edit
  end

  def update
    @cost_calculation_product.assign_attributes(params[:cost_calculation_product])
    #respond_to удалять нельзя, json ответ нужен для best_in_place
    respond_to do |format|
      if @cost_calculation_product.valid? && @cost_calculation_product.update_with_supplier_products
        format.html { redirect_to cost_calculation_build_path(@cost_calculation, 'products')}
        format.json { respond_with_bip(@cost_calculation_product) }
      else
        format.html { render :action => "edit" }
        format.json { respond_with_bip(@cost_calculation_product) }
      end
    end
  end
  def bip_update
    respond_to do |format|
      if @cost_calculation_product.update_attributes(params[:cost_calculation_product])
        format.json { respond_with_bip(@cost_calculation_product) }
      else
        format.json { respond_with_bip(@cost_calculation_product) }
      end
    end
  end
  def destroy
    @cost_calculation_product.destroy
    redirect_to :back
  end

private
  def get_cost_calculation
    if params[:cost_calculation_id].presence
      @cost_calculation = CostCalculation.find(params[:cost_calculation_id])
    else
      @cost_calculation = @cost_calculation_product.cost_calculation
    end
    check_owner
  end

  def check_owner
    unless @cost_calculation.owner?(current_contractor) || current_contractor.ns?
      redirect_to deals_path, notice: I18n.t(:havent_access)
    end
  end

  def get_cost_calculation_product
    @cost_calculation_product = CostCalculationProduct.find(params[:id])
  end
end
