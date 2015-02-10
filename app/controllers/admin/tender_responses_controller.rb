#coding: utf-8
class Admin::TenderResponsesController < Admin::ApplicationController
  before_filter :china?
  
  def toggle_approved
    @tender_response = TenderResponse.find(params[:id])
    @tender_response.save_with_callbacks

    redirect_to :back
  end

  def index
    @tender_responses = TenderResponse.sent.order('created_at DESC')
  end
  
  def new
    @tender_response = TenderResponse.new
    
    render 'edit'
  end
  
  def edit
    @tender_response = TenderResponse.find(params[:id])
    @tender = @tender_response.tender
  end
  
  def create
    @tender_response = TenderResponse.new(params[:tender_response])
    if @tender_response.save
      redirect_to admin_tender_responses_path, :notice => "#{TenderResponse.model_name.human} #{t 'flash.notice.was_added'}"
    else
      render 'edit'
    end
  end

  def update
    @tender_response = TenderResponse.find(params[:id])
    respond_to do |format|
      if @tender_response.update_attributes(params[:tender_response])
        format.html { redirect_to admin_tender_responses_path, :notice => "#{TenderResponse.model_name.human} #{t 'flash.notice.was_updated'}" }
        format.json { respond_with_bip(@tender_response) }
      else
        flash[:notice] = "#{t(:update_after_completion) if @tender.completed?}"
        format.html { render "edit"}
        format.json { respond_with_bip(@tender) }
      end
    end
  end
  
  def destroy
    @tender_response = TenderResponse.find(params[:id])
    @tender_response.destroy
    redirect_to admin_tender_responses_path, :alert => "#{TenderResponse.model_name.human} #{t 'flash.notice.was_deleted'}"
  end
private
  def china?
    if current_user.china?
      redirect_to [:admin, :ns_helps]
    end
  end
end