class ProductProperty < ActiveRecord::Base
  attr_accessible :body, :slug, :title, :product_id
  attr_readonly :product_id
  validates_presence_of :title

  def self.standart
    ['material', 'chemistry composition', 'dimensions']
  end
end
