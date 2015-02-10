class NiceGood < ActiveRecord::Base
  attr_accessible :nice_group_id, :nice_class_id, :number, :title_en, :title_ru

  belongs_to :nice_class
  has_many :products

  def coded_title
    "##{number} - #{title_en}"
  end
  # belongs_to :nice_group

  # delegate :nice_class, to: :nice_group
end
