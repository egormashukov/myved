class SeaFreightExecutionStatus < ActiveRecord::Base
  attr_accessible :booking, :contract, :eta, :etd, :loading, :sea_freight_execution_id, :warehouse

  belongs_to :sea_freight_execution

  def winner? current_contractor
    sea_freight_execution.vedable.winner.contractor == current_contractor
  end
  # def contract=(v al)
  #   @contract = parse_date(val)
  # end

  # def booking=(val)
  #   @booking = parse_date(val)
  # end

  # def eta=(val)
  #   @eta = parse_date(val)
  # end

  # def etd=(val)
  #   @etd = parse_date(val)
  # end

  # def loading=(val)
  #   @loading = parse_date(val)
  # end

  # def parse_date(val)
  #   if val.presence
  #     Date.strptime(val, '%d.%m.%Y')
  #   end
  # end

end
