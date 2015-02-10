class PropertiesController < ApplicationController

  def update
    @product_property = ProductProperty.find(params[:id])
    #respond_to удалять нельзя, json ответ нужен для best_in_place
    respond_to do |format|
      if @product_property.update_attributes(params[:property])
        format.html { redirect_to(@product_property, :notice => 'Product property was successfully updated.') }
        format.json { respond_with_bip(@product_property) }
      else
        format.html { render :action => "edit" }
        format.json { respond_with_bip(@product_property) }
      end
    end
  end

end
