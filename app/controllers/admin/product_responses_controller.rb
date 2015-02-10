#coding: utf-8
class Admin::ProductResponsesController < Admin::ApplicationController
  before_filter :china?

  def update
    @product_response = ProductResponse.find(params[:id])
    respond_to do |format|
      if @product_response.update_attributes(params[:product_response])
        format.json { respond_with_bip(@product_response) }
      else
        flash[:notice] = "#{t(:update_after_completion) if @supplier_product.completed?}"
        format.json { respond_with_bip(@product_response) }
      end
    end
  end

private
  def china?
    if current_user.china?
      redirect_to [:admin, :ns_helps]
    end
  end
end