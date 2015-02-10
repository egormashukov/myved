class BuyerProfile < ActiveRecord::Base
  has_one :contractor, as: :profile

end
