# encoding: utf-8

class SeaFreight::Decline < SeaFreight

  validates :failure_cause, presence: true

  def self.failure_cause_options
    [
      ['торги проводили для сравнения', 'information_gathering'],
      ['высокая стоимость доставки', 'high_delivery_cost'],
      ['запрос потерял актуальность (отменен или перенесен)', 'not_actual']
    ]
  end
end
