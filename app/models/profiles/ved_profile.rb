class VedProfile < ActiveRecord::Base
  has_one :contractor, as: :profile

end
