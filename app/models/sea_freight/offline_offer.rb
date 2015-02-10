class SeaFreight::OfflineOffer < ActiveRecord::Base
  attr_accessible :company, :cost, :sea_freight_id, :transport, :currency
  belongs_to :sea_freight


  validates :company, :cost, :transport, :currency, presence: true

  after_save :send_notifications

  def send_notifications
  	sea_freight.sea_freight_responses.each do |sfr|
  		sea_freight.notifications.build(contractor_id: sfr.contractor_id).set_body(:new_offline_response)
  	end
  end
end
