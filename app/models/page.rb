class Page < ActiveRecord::Base
  extend FriendlyId
  friendly_id :title, use: :slugged
  translates :title, :body
  
  attr_accessible :body, :title, :slug, :translations_attributes
  attr_readonly :slug
  validates_presence_of :title

  accepts_nested_attributes_for :translations
end
