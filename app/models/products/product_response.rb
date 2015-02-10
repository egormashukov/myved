# encoding: utf-8

class ProductResponse < ActiveRecord::Base
  attr_accessible :product_request_id, :supplier_product_id, :tender_response_id, :price, :supplier_product_attributes, :supplier_product_attr, :edit_product
  attr_readonly :product_request_id, :tender_response_id
  attr_accessor :supplier_product_attr, :edit_product

  validates_presence_of :price
  validate :must_have_obligatory_properties

  belongs_to :product_request
  belongs_to :supplier_product
  belongs_to :tender_response

  accepts_nested_attributes_for :supplier_product

  def edit_product?
    ['true', true, '1', 1].include?(self.edit_product)
  end

  def cost
    product_request.quantity * price
  end

  def cost_string
    "#{tender_response.tender.currency}#{cost}"
  end

private

  def must_have_obligatory_properties
    product_request.properties.obligatory.each do |property|
      unless supplier_product.properties.select{|pp| pp.title == property.title}.any? && supplier_product.properties.select{|pp| pp.title == property.title}.first.body.presence
        errors[:properties] << "#{property.title} не может быть пустым"
      end
    end
  end
end
