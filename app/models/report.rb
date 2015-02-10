#encoding: utf-8

class Report

  # extend  ActiveModel::Naming
  # extend  ActiveModel::Translation
  # include ActiveModel::Validations
  # include ActiveModel::Conversion

  attr_accessor :to, :from

  def initialize(attributes = {})
    attributes.try(:each) do |name, value|
      send("#{name}=", value)
    end
  end

  def from_beginning_of_day
    Date.parse(from || '01.06.2013').beginning_of_day
  end

  def to_end_of_day
    Date.parse(to || Time.now.strftime('%d-%m-%Y')).end_of_day
  end

  def sea_freights_count
    SeaFreight.not_new.where(created_at: from_beginning_of_day..to_end_of_day).count
    # ТОРГИ ПО ДОСТАВКЕ
    # зашли/вышли, не переходили на второй шаг
    # перешли дальше, но не отправили
    # торги с выбором победилтеля
    # торги без выбора победителя
      # причина 1
      # причина 2
      # причина 3
  end

  def registrations_count
    Contractor.where(created_at: from_beginning_of_day..to_end_of_day).count
  end

  def authorizations_count
    Contractor.where(authorized: true).where(created_at: from_beginning_of_day..to_end_of_day).count
    # зашли/вышли, не переходили на второй шаг
    # перешли дальше, но не отправили
    # успешно авторизованы
  end

  def cost_calculations_count
    CostCalculation.except_new.where(created_at: from_beginning_of_day..to_end_of_day).count
    # Расчет себестоимости
    # зашли/вышли, не переходили на второй шаг
    # перешли дальше, но не отправили
    # согласились на предложение
  end

  def tenders_count
    Tender.without_new.where(created_at: from_beginning_of_day..to_end_of_day).count
  end

  def sea_freights_repeated_count
    contractor_ids =  SeaFreight.all.map(&:contractor_id)
    contractor_ids.map!{|c| contractor_ids.map{|id| c == id}.count > 1}
    SeaFreight.where(contractor_id: contractor_ids).not_new.where(created_at: from_beginning_of_day..to_end_of_day).count
  end

  def sea_freight_executions_count
    VedRequest.where(type: ['SeaFreightExecutionRailway', 'SeaFreightExecutionSea', 'SeaFreightExecutionSeaAuto', 'SeaFreightExecutionSeaRailway']).where(created_at: from_beginning_of_day..to_end_of_day).count
  end
    
end