class ExchangeRate < ActiveRecord::Base
  attr_accessible :eur_rub, :usd_rub, :actual_date
  has_many :sea_freights

  scope :by_actual, -> { order('actual_date DESC') }

  def to_s
    value
  end

  def rub_usd
    1 / usd_rub.to_f
  end

  def eur_usd
    (eur_rub.to_f / usd_rub.to_f).round(4)
  end

  def usd_usd
    1
  end
end
