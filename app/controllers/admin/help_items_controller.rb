#coding: utf-8
class Admin::HelpItemsController < Admin::ApplicationController
  helper_method :sort_column, :sort_direction
  before_filter :china?
  
  def toggleshow
    @help_item = HelpItem.find(params[:id])
    @help_item.toggle(:visible)
    @help_item.save
    render :nothing => true
  end

  def sort
    params[:help_item].each_with_index do |id, idx|
      @help_item = HelpItem.find(id)
      @help_item.position = idx
      @help_item.save
    end
    render :nothing => true
  end

  def index
    @category = params[:category].presence || HelpItem.categories.first
    @help_items = HelpItem.by_category(@category).order(sort_column + " " + sort_direction)
  end
  
  def new
    @help_item = HelpItem.new
    render 'edit'
  end
  
  def edit
    @help_item = HelpItem.find(params[:id])
  end
  
  def create
    @help_item = HelpItem.new(params[:help_item])
    if @help_item.save
      redirect_to admin_help_items_path(category: @help_item.category), :notice => "#{HelpItem.model_name.human} #{t 'flash.notice.was_added'}"
    else
      render 'edit'
    end
  end

  def update
    @help_item = HelpItem.find(params[:id])
    if @help_item.update_attributes(params[:help_item])
      redirect_to admin_help_items_path(category: @help_item.category), :notice => "#{HelpItem.model_name.human} #{t 'flash.notice.was_updated'}"
    else
      render 'edit'
    end
  end
  
  def destroy
    @help_item = HelpItem.find(params[:id])
    @help_item.destroy
    redirect_to admin_help_items_path, :alert => "#{HelpItem.model_name.human} #{t 'flash.notice.was_deleted'}"
  end

  private
  def china?
    if current_user.china?
      redirect_to [:admin, :ns_helps]
    end
  end
  def sort_column
    HelpItem.column_names.include?(params[:sort]) ? params[:sort] : 'position'
  end
  
  def sort_direction
    %w[asc desc].include?(params[:direction]) ? params[:direction] : "asc"
  end  
end