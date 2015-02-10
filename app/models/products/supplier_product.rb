class SupplierProduct < Product 
  attr_accessible :hs_code, :contractor_id, :product_request_id, :advantages_attributes, :properties_attributes, :net_weight, :gross_weight,  :package,  :ved_code, :volume
  attr_readonly :contractor_id
  attr_accessor :product_request_id

  #validates_presence_of :id_code
  has_many :product_requests, through: :product_responses
  has_many :product_responses, dependent: :destroy

  has_many :cost_calculations, :through => :cost_calculation_products
  has_many :cost_calculation_products, dependent: :destroy

  has_many :advantages, foreign_key: 'product_id', dependent: :destroy
  has_many :properties, foreign_key: 'product_id', dependent: :destroy

  belongs_to :contractor
  
  accepts_nested_attributes_for :advantages, :properties,allow_destroy: true

  def owner?(current_contractor)
    contractor == current_contractor
  end

end