# encoding: utf-8

class CostCalculation::Decline < CostCalculation

  validates :failure_cause, presence: true

  def self.failure_cause_options
    [
      ['просчет проводили для сбора информации', 'information_gathering'],
      ['высокие таможенные платежи','high_customs'],
      ['высокая стоимость доставки','high_delivery_cost'],
      ['высокие прочие расходы','high_others'],
    ]
  end
end
