class TenderProduct < ActiveRecord::Base
  attr_accessible :product_id, :tender_id
  attr_readonly :product_id, :tender_id
  belongs_to :product
  belongs_to :tender
end
