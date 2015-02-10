class Product < ActiveRecord::Base
  attr_accessible :title, :id_code, :image, :image_cache, :marking_of_goods, :model, :price, :requirements, :application_field, :properties_attributes, :nice_good_id

  validates_presence_of :title, :application_field

  mount_uploader :image, ProductImageUploader

  has_many :properties, dependent: :destroy
  belongs_to :nice_good
  accepts_nested_attributes_for :properties, allow_destroy: true

  def id_code
    nice_good.try(:coded_title)
  end
end
