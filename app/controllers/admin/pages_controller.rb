#coding: utf-8
class Admin::PagesController < Admin::ApplicationController
  helper_method :sort_column, :sort_direction
  before_filter :china?

  def index
    @pages = Page.order(sort_column + " " + sort_direction)
  end
  
  def new
    @page = Page.new
    render 'edit'
  end
  
  def edit
    @page = Page.find(params[:id])
  end
  
  def create
    @page = Page.new(params[:page])
    if @page.save
      redirect_to admin_pages_path, :notice => "#{Page.model_name.human} #{t 'flash.notice.was_added'}"
    else
      render 'edit'
    end
  end

  def update
    @page = Page.find(params[:id])
    if @page.update_attributes(params[:page])
      redirect_to admin_pages_path, :notice => "#{Page.model_name.human} #{t 'flash.notice.was_updated'}"
    else
      render 'edit'
    end
  end
  
  def destroy
    @page = Page.find(params[:id])
    @page.destroy
    redirect_to admin_pages_path, :alert => "#{Page.model_name.human} #{t 'flash.notice.was_deleted'}"
  end

  private
  
  def china?
    if current_user.china?
      redirect_to [:admin, :ns_helps]
    end
  end

  def sort_column
    Page.column_names.include?(params[:sort]) ? params[:sort] : 'created_at'
  end
  
  def sort_direction
    %w[asc desc].include?(params[:direction]) ? params[:direction] : "asc"
  end  
end