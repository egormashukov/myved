class ProductRequestsController < ApplicationController
  before_filter :authenticate_contractor!
  before_filter :get_tender
  before_filter :check_show, only: :show
  before_filter :check_owner, only: [:edit, :update]
  def show
  end

  def edit
  end

  def update
    @product_request = ProductRequest.find(params[:id])
    #respond_to удалять нельзя, json ответ нужен для best_in_place
    respond_to do |format|
      if @product_request.update_attributes(params[:product_request])

        @tender.notifications.build(contractor_id: Contractor.ns.id).set_body(:update_tender)

        @tender.tender_responses.each do |response|
          @tender.notifications.build(contractor_id: response.contractor_id).set_body(:update_tender)
        end

        format.html { redirect_to @tender }
        format.json { respond_with_bip(@product_request) }
      else
        format.html { render 'edit' }
        format.json { respond_with_bip(@product_request) }
      end
    end
  end

private

  def get_tender
    @product_request = ProductRequest.find(params[:id])
    @tender = @product_request.tender
  end
  
  def check_owner
    unless @tender.owner?(current_contractor) || current_contractor.ns?
      redirect_to @tender, notice: I18n.t(:havent_access)
    end
  end

  def check_show
    unless @tender.visible_for?(current_contractor) || current_contractor.ns? || current_contractor.china?
      redirect_to deals_path, notice: I18n.t(:havent_access)
    end
  end
end
