class SupplierProductsController < ApplicationController

  def index
   @supplier_products = current_contractor.supplier_products
  end

  def show
    @supplier_product = SupplierProduct.find(params[:id])
    respond_to do |format|
      format.html 
      format.json  { render :json => @supplier_product.to_json(:only => [:title, :model, :application_field, :hs_code, :ved_code, :marking_of_goods, :package, :net_weight, :gross_weight], :include => { :properties => { :only => [:id, :title, :body] } }) }
    end
  end

  def new
   @supplier_product = SupplierProduct.new
  end

  def edit
    @supplier_product = SupplierProduct.find(params[:id])
  end

  def create
    @supplier_product = SupplierProduct.new(params[:supplier_product])
    @supplier_product.contractor = current_contractor
    
    if @supplier_product.save
      redirect_to @supplier_product, notice: 'Product was successfully created.'
    else
      render action: "new" 
    end
  end

  def update
    @supplier_product = SupplierProduct.find(params[:id])
    respond_to do |format|
      if @supplier_product.update_attributes(params[:supplier_product])
        format.html {redirect_to @supplier_product, notice: 'Product was successfully updated.'}
        format.json { respond_with_bip(@supplier_product) }
      else
        format.html {render action: "edit"}
        format.json { respond_with_bip(@cost_calculation_product) }
      end
    end
  end

  def destroy
    @supplier_product = SupplierProduct.find(params[:id])
    @supplier_product.destroy
  end

private

  def check_owner
    unless @tender.owner?(current_contractor)
      redirect_to @tender, notice: I18n.t(:havent_access)
    end
  end

  def check_show
    unless @tender.visible_for?(current_contractor)
      redirect_to tenders_path, notice: I18n.t(:havent_access)
    end
  end

end