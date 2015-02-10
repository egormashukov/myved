# encoding: utf-8

class TransportUnit < ActiveRecord::Base
  attr_accessible :transportable_id, :transportable_type, :transport, :quantity, :max_weight, :weight_units

  belongs_to :transportable, polymorphic: true

  validates :transport, :quantity, presence: true
  validates :weight_units, :max_weight, presence: true, if: :sea_freight?
  # validates_presence_of :volume, if: :avia?
  
  def avia?
    transport == 'авиа'
  end

  def self.weight_units_options
    [
      ['кг', 'kg'],
      ['тонны', 't']
    ]
  end

  def sea_freight?
    transportable_type == 'SeaFreight'
  end

  def self.transport_options
    {
      '1.Контейнер' => ['20 DV', '40 DV', '40 HC'],
      '2.Рефрижераторный контейнер' => ['20 Ref', '40 Ref', '40 HCRef'],
      '3.Автопоезд или тентованный автомобиль' => ['тент 86 м3', 'тент 120 м3'],
      '4.Авиагруз' => ['авиа'],
      '5.Другое' => ['другое']
    }
  end

  def self.sea_freight_transport_options
    {
      '1.Контейнер' => ['20 DV', '40 DV', '40 HC'],
      '2.Рефрижераторный контейнер' => ['20 Ref', '40 Ref', '40 HCRef'],
      '3.Другое' => [['Укажите тип контейнера в описании', "other"]],
    }
  end
end
