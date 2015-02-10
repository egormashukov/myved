class ProductRequest < Product 
  attr_accessible :quantity, :quantity_unit#, :model_obligatory, :id_code_obligatory, :price_obligatory, :quantity_obligatory, :application_field_obligatory

  has_many :supplier_products, through: :product_responses
  has_many :product_responses, dependent: :destroy

  belongs_to :tender
  validates_presence_of :quantity, :quantity_unit#, :nice_good_id

  def self.summary_table_attrs
    [:title, :id_code, :application_field]
  end

  def quantity_string
    "#{quantity} #{quantity_unit}"
  end
  def cost
    quantity * price if quantity.presence && price.presence
  end
  def cost_string
    "#{tender.currency}#{cost}"
  end
end
