class CostCalculationProduct < ActiveRecord::Base
  attr_accessible :cost_calculation_id, :supplier_product_id, :supplier_product_attributes, :price, :quantity, :quantity_unit, :supplier_product_attr, :edit_product, :sum_net_weight, :sum_gross_weight, :sum_volume
  attr_accessor :supplier_product_attr, :edit_product
  
  validates_presence_of :price, :quantity, :quantity_unit

  belongs_to :cost_calculation, inverse_of: :cost_calculation_products
  belongs_to :supplier_product
  accepts_nested_attributes_for :supplier_product

  def edit_product?
    ['true', true, '1', 1].include?(self.edit_product)
  end

  def summ_cost
    price*quantity
  end
  def save_with_supplier_products
    if self.edit_product?
      sp_attrs = accessible_attrs_hash(self.supplier_product)
      supplier = SupplierProduct.find(self.supplier_product_attr)
      supplier.properties.destroy_all
      self.supplier_product.properties.each do |property|
        supplier.properties << property
      end
      self.supplier_product = supplier
      # место неоднозначное. Не очень ясно, как быть с валидациями
      supplier.assign_attributes(sp_attrs)
      supplier.save
    end
    save
  end

  def update_with_supplier_products
    if self.edit_product? && self.supplier_product_id.to_s != self.supplier_product_attr.to_s
      sp_attrs = accessible_attrs_hash(self.supplier_product)
      supplier = SupplierProduct.find(self.supplier_product_attr)
      supplier.properties.destroy_all
      supplier.properties << self.supplier_product.properties
      self.supplier_product = supplier
      # место неоднозначное. Не очень ясно, как быть с валидациями
      supplier.assign_attributes(sp_attrs)
      supplier.save
    elsif !self.edit_product?
      sp_attrs = accessible_attrs_hash(self.supplier_product)
      supplier = SupplierProduct.new(sp_attrs)
      self.supplier_product.properties.each do |property|
        supplier.properties.build(title: property.title, body: property.body)
      end
      self.supplier_product = supplier
      # место неоднозначное. Не очень ясно, как быть с валидациями
    end
    save
  end

private

  def accessible_attrs_hash(obj)
    attrs = obj.attributes
    classname = eval(obj.class.name)
    protected_attrs = classname.new.attributes.keys - classname.accessible_attributes.to_a
    protected_attrs.each do |pa|
      attrs.delete(pa)
    end
    attrs   
  end
end
