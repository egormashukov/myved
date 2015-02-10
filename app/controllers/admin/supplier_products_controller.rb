#coding: utf-8
class Admin::SupplierProductsController < Admin::ApplicationController
  helper_method :sort_column, :sort_direction
  before_filter :china?

  def index
    @supplier_products = SupplierProduct.order(sort_column + " " + sort_direction)
  end
  
  def new
    @supplier_product = SupplierProduct.new
    render 'edit'
  end
  
  def edit
    @supplier_product = SupplierProduct.find(params[:id])
  end
  
  def create
    @supplier_product = SupplierProduct.new(params[:supplier_product])
    if @supplier_product.save
      redirect_to admin_supplier_products_path, :notice => "#{SupplierProduct.model_name.human} #{t 'flash.notice.was_added'}"
    else
      render 'edit'
    end
  end

  def update
    @supplier_product = SupplierProduct.find(params[:id])
    respond_to do |format|
      if @supplier_product.update_attributes(params[:supplier_product])
        format.json { respond_with_bip(@supplier_product) }
      else
        flash[:notice] = "#{t(:update_after_completion) if @supplier_product.completed?}"
        format.json { respond_with_bip(@supplier_product) }
      end
    end
  end
  
  def destroy
    @supplier_product = SupplierProduct.find(params[:id])
    @supplier_product.destroy
    redirect_to admin_supplier_products_path, :alert => "#{SupplierProduct.model_name.human} #{t 'flash.notice.was_deleted'}"
  end

  private
  
  def china?
    if current_user.china?
      redirect_to [:admin, :ns_helps]
    end
  end

  def sort_column
    SupplierProduct.column_names.include?(params[:sort]) ? params[:sort] : 'created_at'
  end
  
  def sort_direction
    %w[asc desc].include?(params[:direction]) ? params[:direction] : "asc"
  end  
end