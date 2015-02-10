#coding: utf-8
class Admin::DealsController < Admin::ApplicationController
  helper_method :sort_column, :sort_direction
  before_filter :china?
  
  def index
    @deals = Deal.order(sort_column + " " + sort_direction)
  end
  
  def new
    @deal = Deal.new
    render 'edit'
  end
  
  def edit
    @deal = Deal.find(params[:id])
  end
  
  def create
    @deal = Deal.new(params[:deal])
    if @deal.save
      redirect_to admin_deals_path, :notice => "#{Deal.model_name.human} #{t 'flash.notice.was_added'}"
    else
      render 'edit'
    end
  end

  def update
    @deal = Deal.find(params[:id])
    if @deal.update_attributes(params[:deal])
      redirect_to admin_deals_path, :notice => "#{Deal.model_name.human} #{t 'flash.notice.was_updated'}"
    else
      render 'edit'
    end
  end
  
  def destroy
    @deal = Deal.find(params[:id])
    @deal.destroy
    redirect_to admin_deals_path, :alert => "#{Deal.model_name.human} #{t 'flash.notice.was_deleted'}"
  end

  private
  def china?
    if current_user.china?
      redirect_to [:admin, :ns_helps]
    end
  end
  def sort_column
    Deal.column_names.include?(params[:sort]) ? params[:sort] : 'created_at'
  end
  
  def sort_direction
    %w[asc desc].include?(params[:direction]) ? params[:direction] : "asc"
  end  
end