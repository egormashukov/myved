#coding: utf-8
class Admin::ReviewsController < Admin::ApplicationController
  helper_method :sort_column, :sort_direction
  before_filter :china?
  
  def index
    @reviews = Review.order('created_at DESC')
  end
  
  def new
    @review = Review.new
    render 'edit'
  end
  
  def edit
    @review = Review.find(params[:id])
  end
  
  def create
    @review = Review.new(params[:review])
    if @review.save
      redirect_to admin_reviews_path, :notice => "#{Review.model_name.human} #{t 'flash.notice.was_added'}"
    else
      render 'edit'
    end
  end

  def update
    @review = Review.find(params[:id])
    if @review.update_attributes(params[:review])
      redirect_to admin_reviews_path, :notice => "#{Review.model_name.human} #{t 'flash.notice.was_updated'}"
    else
      render 'edit'
    end
  end
  
  def destroy
    @review = Review.find(params[:id])
    @review.destroy
    redirect_to admin_reviews_path, :alert => "#{Review.model_name.human} #{t 'flash.notice.was_deleted'}"
  end

  private
  def china?
    if current_user.china?
      redirect_to [:admin, :ns_helps]
    end
  end
  def sort_column
    Review.column_names.include?(params[:sort]) ? params[:sort] : 'created_at'
  end
  
  def sort_direction
    %w[asc desc].include?(params[:direction]) ? params[:direction] : "asc"
  end  
end