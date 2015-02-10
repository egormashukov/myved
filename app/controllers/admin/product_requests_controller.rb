#coding: utf-8
class Admin::ProductRequestsController < Admin::ApplicationController
  helper_method :sort_column, :sort_direction
  before_filter :china?

  def index
    @product_requests = ProductRequest.order(sort_column + " " + sort_direction)
  end
  
  def new
    @product_request = ProductRequest.new
    render 'edit'
  end
  
  def edit
    @product_request = ProductRequest.find(params[:id])
  end
  
  def create
    @product_request = ProductRequest.new(params[:product_request])
    if @product_request.save
      redirect_to admin_product_requests_path, :notice => "#{ProductRequest.model_name.human} #{t 'flash.notice.was_added'}"
    else
      render 'edit'
    end
  end

  def update
    @product_request = ProductRequest.find(params[:id])
    if @product_request.update_attributes(params[:product_request])
      redirect_to admin_product_requests_path, :notice => "#{ProductRequest.model_name.human} #{t 'flash.notice.was_updated'}"
    else
      render 'edit'
    end
  end
  
  def destroy
    @product_request = ProductRequest.find(params[:id])
    @product_request.destroy
    redirect_to admin_product_requests_path, :alert => "#{ProductRequest.model_name.human} #{t 'flash.notice.was_deleted'}"
  end

  private
  
  def china?
    if current_user.china?
      redirect_to [:admin, :ns_helps]
    end
  end

  def sort_column
    ProductRequest.column_names.include?(params[:sort]) ? params[:sort] : 'created_at'
  end
  
  def sort_direction
    %w[asc desc].include?(params[:direction]) ? params[:direction] : "asc"
  end  
end