class SupplierProfile < ActiveRecord::Base
  has_one :contractor, as: :profile

end
