# encoding: utf-8

module TendersHelper

  def tender_date_unites(tender)
    if I18n.locale == :ru
      Russian.p(tender.delivery_time, tender.plural_date[0], tender.plural_date[1], tender.plural_date[2], tender.plural_date[3]) if tender.delivery_time.presence
    else
      'day'.pluralize(tender.delivery_time) if tender.delivery_time.presence
    end
  end

  def summary_cell_style_eq(tender_response, tender)
    if tender_response != tender
      'not_equal_attr'
    end
  end

  def summary_cell_style_more(less_val, more_val)
    if less_val.presence  && more_val.presence && less_val > more_val
      'not_equal_attr'
    end
  end

  def deal_destroy_button(deal)
    if deal.new_in_all_states?
      link_to t("actions.delete"), deal, method: :delete, confirm: 'Вы уверены, что хотите удалить проект?'
    end
  end
end
