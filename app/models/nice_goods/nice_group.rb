class NiceGroup < ActiveRecord::Base
  attr_accessible :nice_class_id, :number, :title_en, :title_ru

  belongs_to :nice_class
  has_many :nice_goods
end