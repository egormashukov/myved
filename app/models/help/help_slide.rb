class HelpSlide < ActiveRecord::Base
  default_scope includes(:translations)
  attr_accessible :body, :help_item_id, :position, :title, :visible, :translations_attributes

  belongs_to :help_item
  translates :title, :body

  accepts_nested_attributes_for :translations
  
  def next
    help_item.help_slides.visible_by_position.where("position > ?", position).first
  end
  def prev
    help_item.help_slides.visible.order("position DESC").where("position < ?", position).first
  end
  def element_index(help_slides)
    index = ''
    help_slides.each_with_index do |help_slide, idx|
      index = idx if help_slide.id == id
    end
    index + 1
  end
end
