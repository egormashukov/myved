# encoding: utf-8

class NiceClass < ActiveRecord::Base
  attr_accessible :heading_en, :heading_ru, :number

  has_many :nice_groups
  has_many :nice_goods, order: 'number'#, through: :nice_groups
  
  scope :for_select, -> {order(:number)}

  def self.id_codes_hash
    scoped.all.collect{|nice_class| [nice_class.heading_ru, nice_class.heading_ru]}
  end

  def numbered_title
    "Класс #{number}. #{heading_ru}"
  end
end
