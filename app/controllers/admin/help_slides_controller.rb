#coding: utf-8
class Admin::HelpSlidesController < Admin::ApplicationController
  before_filter :get_help_slide, except: [:create, :new, :sort]
  before_filter :get_help_item, except: [:destroy, :toggleshow, :sort]
  before_filter :china?

  def toggleshow
    @help_slide.toggle(:visible)
    @help_slide.save
    redirect_to :back
  end
  def sort
    params[:help_slide].each_with_index do |id, idx|
      HelpSlide.find(id).update_attributes(position: idx)
    end
    render :nothing => true
  end
  def new
    @help_slide = @help_item.help_slides.build
    render 'edit'
  end
  
  def edit
  end
  
  def create
    @help_slide = @help_item.help_slides.build(params[:help_slide])
    if @help_slide.save
      if params[:apply].presence
        redirect_to [:edit, :admin, @help_item, @help_slide], :notice => "#{HelpSlide.model_name.human} #{t 'flash.notice.was_added'}"
      else
        redirect_to [:edit, :admin, @help_item], :notice => "#{HelpSlide.model_name.human} #{t 'flash.notice.was_added'}"
      end
    else
      render 'edit'
    end
  end

  def update
    @help_item = @help_slide.help_item
    if @help_slide.update_attributes(params[:help_slide])
      if params[:apply].presence
        redirect_to [:edit, :admin, @help_item, @help_slide], :notice => "#{HelpSlide.model_name.human} #{t 'flash.notice.was_updated'}"
      else
        redirect_to [:edit, :admin, @help_item], :notice => "#{HelpSlide.model_name.human} #{t 'flash.notice.was_updated'}"
      end
    else
      render 'edit'
    end
  end
  
  def destroy
    @help_slide.destroy
    redirect_to [:edit, :admin, @help_slide.help_item], :alert => "#{HelpSlide.model_name.human} #{t 'flash.notice.was_deleted'}"
  end

  private
  def china?
    if current_user.china?
      redirect_to [:admin, :ns_helps]
    end
  end
  def get_help_slide
    @help_slide = HelpSlide.find(params[:id])
  end
  def get_help_item
    @help_item = HelpItem.find(params[:help_item_id])
  end
end