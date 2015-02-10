class HelpItemsController < ApplicationController

  def show
    @help_item = HelpItem.find(params[:id])
    @help_slides = @help_item.help_slides.visible_by_position
    @help_slide = @help_slides.first
    if contractor_signed_in?
      render partial: 'show'
    end
  end

  def privacy
    GeneralRule.visible.order('created_at DESC').each do |p|
      if p.file_location.to_s.present?
        return send_file "#{Rails.root}/public/#{p.real_file_location}", disposition: 'inline'
      end
    end
    render nothing: true
  end

  def help
    @help_item = HelpItem.find(params[:id])
    @help_slides = @help_item.help_slides.visible_by_position
  end

  def vote
    @help_item = HelpItem.find(params[:id])
    @help_item.vote(current_contractor)
  end

  def next
    @help_item = HelpItem.find(params[:id])
    @help_slides = @help_item.help_slides.visible_by_position
    @help_slide = @help_slides.find(params[:help_slide_id]).next
    render partial: 'show'
  end

  def prev
    @help_item = HelpItem.find(params[:id])
    @help_slides = @help_item.help_slides.visible_by_position
    @help_slide = @help_slides.find(params[:help_slide_id]).prev
    render partial: 'show'
  end
end