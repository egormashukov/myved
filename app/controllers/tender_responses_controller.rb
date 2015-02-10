class TenderResponsesController < ApplicationController
  before_filter :authenticate_contractor!
  before_filter :get_tender
  before_filter :check_new, :only => [:new, :create]
  before_filter :check_owner, :except => [:new, :create, :show]
  before_filter :check_show, :only => :show
  before_filter :tender_response_exists?, :only => [:new, :create]
  before_filter :get_messages

  def send_to_ns
    @tender_response = TenderResponse.find(params[:id])
    @tender_response.send_to_ns
    @tender = @tender_response.tender

    @tender.notifications.build(contractor_id: @tender_response.contractor_id).set_body(:new_response)
    @tender.notifications.build(contractor_id: Contractor.ns.id).set_body(:new_response_to_myved)
    redirect_to @tender_response.tender, notice: I18n.t("notice.tender_response.send_to_ns")
  end

  def show
    @tender_response = TenderResponse.find(params[:id])
  end

  # GET /tender_responses/new
  # GET /tender_responses/new.json
  def new
    @tender_response = @tender.tender_responses.build
  end

  # GET /tender_responses/1/edit
  def edit
  end

  # POST /tender_responses
  # POST /tender_responses.json
  def create
    @tender_response = @tender.tender_responses.build(params[:tender_response])
    @tender_response.contractor = current_contractor

    if @tender_response.valid? && @tender_response.save_with_product_requests
      redirect_to [@tender, @tender_response], notice: I18n.t("notice.tender_response.send_to_ns")
    else
      render "new"
    end
  end

  # PUT /tender_responses/1
  # PUT /tender_responses/1.json
  def update
    @tender_response.assign_attributes(params[:tender_response])
    
    if @tender_response.increment_updated_count && !@tender_response.tender.completed? && @tender_response.valid? && @tender_response.update_with_product_requests
      
      if @tender_response.new?
        redirect_to [@tender, @tender_response], notice: I18n.t("notice.tender_response.update")
      else
        redirect_to @tender, notice: I18n.t("notice.tender_response.update")
      end
    else
      flash[:notice] = "#{t(:update_after_completion) if @tender_response.tender.completed?}"
      render "edit"
    end

  end

  # DELETE /tender_responses/1
  # DELETE /tender_responses/1.json
  def destroy
    @tender_response.destroy
    redirect_to @tender
  end

private

  def tender_response_exists?
    if @tender.answer_by(current_contractor)
      redirect_to [:edit, @tender, @tender.answer_by(current_contractor)]
    end
  end

  def check_owner
    @tender_response = TenderResponse.find(params[:id])
    if (@tender_response.contractor_id != current_contractor.id || @tender_response.tender.completed?) && !current_contractor.ns?
      redirect_to @tender_response.tender, notice: I18n.t(:havent_access)
    end
  end

  def get_messages
    @messages = @tender.messages.for_current_contractor(current_contractor.id).ordered.grouped_and_sorted_by_contractor(current_contractor)
    @receivers = current_contractor.context_receivers(@tender)
  end

  def get_tender
    @tender = Tender.find(params[:tender_id])
  end

  def check_new
    unless @tender.active?
      redirect_to tenders_path, notice: I18n.t(:havent_access)
    end
  end

  def check_show
    @tender_response = TenderResponse.find(params[:id])
    unless @tender_response.visible_for?(current_contractor) || current_contractor.ns?
      redirect_to @tender_response.tender, notice: I18n.t(:havent_access)
    end
  end
end
