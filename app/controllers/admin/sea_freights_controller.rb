#coding: utf-8
class Admin::SeaFreightsController < Admin::ApplicationController
  helper_method :sort_column, :sort_direction
  before_filter :set_sea_freight, only: [:approve, :edit, :update, :destroy, :add_contractors, :send_invitations]
  
  def approve
    @sea_freight.approve
    @sea_freight.set_dates
    @sea_freight.notifications.build(contractor_id: @sea_freight.contractor_id).set_body(:approved)
    @sea_freight.project_contractors.each do |pc|
      pc.to_current
    end
    redirect_to :back
  end
  
  def add_contractors
  end

  def send_invitations
    params[:contractor_ids].each do |ci|
      unless @sea_freight.sea_freight_responses.find_by_contractor_id(ci).presence
        @sea_freight.sea_freight_responses.create(contractor_id: ci) 
        pc = @sea_freight.project_contractors.create(contractor_id: ci)
        pc.to_current if @sea_freight.approved?
      end
    end

    redirect_to :back, notice: 'приглашения разосланы'
  end

  def index
    @sea_freights = SeaFreight.sent.order("created_at DESC")
  end
  
  def new
    @sea_freight = SeaFreight.new
    render 'edit'
  end
  
  def edit
  end
  
  def create
    @sea_freight = SeaFreight.new(params[:sea_freight])
    if @sea_freight.save
      redirect_to admin_sea_freights_path, :notice => "#{SeaFreight.model_name.human} #{t 'flash.notice.was_added'}"
    else
      render 'edit'
    end
  end

  def update
    if @sea_freight.update_attributes(params[:sea_freight])
      redirect_to admin_sea_freights_path, :notice => "#{SeaFreight.model_name.human} #{t 'flash.notice.was_updated'}"
    else
      render 'edit'
    end
  end
  
  def destroy
    @sea_freight.destroy
    redirect_to admin_sea_freights_path, :alert => "#{SeaFreight.model_name.human} #{t 'flash.notice.was_deleted'}"
  end

  private

  def set_sea_freight
    @sea_freight = SeaFreight.find(params[:id])
  end

  def sort_column
    SeaFreight.column_names.include?(params[:sort]) ? params[:sort] : 'created_at'
  end
  
  def sort_direction
    %w[asc desc].include?(params[:direction]) ? params[:direction] : "desc"
  end  
end