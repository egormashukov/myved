# encoding: utf-8
class SeaFreightResponseDecorator < MainDecorator
  delegate_all

  def label(field)
    SeaFreightResponse.human_attribute_name(field)
  end

  def fifo_currecied
    currecied(:fifo)
  end

  def filo_currecied
    currecied(:filo)
  end

  def railway_charges_currecied
    currecied(:railway_charges)
  end

  def port_charges_currecied
    currecied(:port_charges)
  end

  def tracking_currecied
    currecied(:tracking)
  end

  def total_currecied
    return '' if new?
    currecied(:total, 'USD')
  end

  def category_string
    value_from_options(:category)
  end

  def currecied(field, currency = nil)
    return '' unless  try(field).presence && try(field).to_f > 0
    currency_string = currency.presence || currency_options.find { |sf| sf[1] == try("#{field}_currency") }.try(:first).presence

    "#{try(field).to_f.round(2)} #{currency_string} #{vat_string(field)}".html_safe
  end

  def vat_string(field)
    return '' unless has_attribute?("#{field}_vat".to_sym)
    val = try("#{field}_vat".to_sym)
    return '' if val == 0
    content_tag(:i, "(с НДС #{val}%)", class: 'vat__caption')
  end

  def value_from_options(field)
    option(field) || try(field)
  end

  def option(field)
    from_option(field, SeaFreightResponse)
  end

  def contractor_for_current
    return contractor_title if sea_freight.decorate.owner_or_ns?
    "Контрагент №#{sea_freight.sea_freight_response_ids.sort.index(id) + 1}"
  end

  def contractor_title
    link_to contractor.title, contractor_path(contractor, sea_freight_response_id: id), class: 'blue_link'
  end

  def attemptes_left
    updated_count == 3 ? 'нет' : (3 - updated_count)
  end

  def payment_conditions
    'Счета выставляются в рублях по курсу ЦБ на дату выставления счета + 1.5% (но не менее 200 USD на возмещение расходов банка по валютным операциям). '
  end
end
