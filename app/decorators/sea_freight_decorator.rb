# encoding: utf-8

class SeaFreightDecorator < MainDecorator
  delegate_all
  include ActionView::Helpers::UrlHelper

  def label(field)
    SeaFreight.human_attribute_name(field)
  end

  def ident
    # {}"#{1 + 100}/#{date_string(:end_date)}"
    101
  end

  def participants_number(sea_freight_responses)
    return '' unless owner? current_contractor
    field_row label(:participants_number), sea_freight_responses.count
  end

  def transport_string
    value_from_options(:transport)
  end

  def hazard_string
    value_from_options(:hazard)
  end

  def decline_string
    from_option(:failure_cause, SeaFreight::Decline) || try(:failure_cause)
  end

  def requirements_string
    value_from_options(:requirements)
  end

  def end_date_execution
    end_date
  end

  def contractor_title
    link_to contractor.title, contractor, class: 'blue_link'
  end

  def sum_table_row(sea_f_responses, field)
    content_tag :tr do
      sum_table_lbl(field) + sum_table_cells(sea_f_responses, field)
    end
  end

  def sum_table_lbl(field)
    content_tag :td, SeaFreightResponse.human_attribute_name(field)
  end

  def sum_table_cells(sea_f_responses, field)
    raw(sea_f_responses.map { |sf_response| content_tag(:td, sf_response.try(field)) }.join) + raw(empty_cells sea_f_responses.count)
  end

  def best_label(current_best)
    if owner? current_contractor
      txt = (has_winner? ? 'Победитель' : 'Лучшее предложение myVED')
    elsif 
      txt = (current_best.try(:contractor) == current_contractor ? 'Ваше предложение лучшее' : 'Лучшее предложение у другого участника')
    end
    content_tag :h2, txt
  end

  def add_response_btn(current_response)
    return '' unless can_response?(current_contractor.id) && !completed?
    txt = (current_response.new? ? 'добавить ответ' : 'ответить')
    link_to txt, [:edit, self, current_response], class: 'main_button'
  end

  def edit_btn
    return '' unless owner_or_ns? && waiting?
    link_to t(:edit), [:edit, self], class: 'main_button'
  end

  def execution_btn
    return '' if !successful? || [winner.try(:contractor_id), contractor_id, Contractor.ns.id].exclude?(current_contractor.id)
    link_to 'исполнение', sea_freight_execution_path(sea_freight_execution), class: 'main_button'
  end

  def open_message_link(response)
    if owner?(current_contractor)
      link_to_messages(self, Contractor.ns, 'написать myVED')
    elsif current_contractor.ns?
      link_to_messages(self, contractor, 'написать клиенту')
    elsif current_contractor.ved_contractor? && contractor.authorized?# && !response.new?
      ved_contractor_messages_links
    end
  end

  def ved_contractor_messages_links
    link_to_messages(self, contractor, 'написать клиенту') + link_to_messages(self, Contractor.ns, 'написать myVED')
  end

  def empty_cells(responses_count)
    return '' unless owner_or_ns?
    c = ''
    unless responses_count > SeaFreight::FAKE_PARTICIPANTS
      (SeaFreight::FAKE_PARTICIPANTS - responses_count).times do
        c += content_tag(:td)
      end
    end
    raw c
  end

  def reject_all_link
    return '' unless can_reject?
    link_or_auth do
      link_to 'отказать всем', [:new, self, :decline], confirm: 'Вы уверены, что хотите отказать всем участникам торгов?'
    end
  end

  def option(field)
    from_option(field, SeaFreight)
  end

  def state_label
    content_tag :span, state_string, class: 'lk-label _blue'
  end

  def decide_link(sea_freight_response)
    link_or_auth do
      if sea_freight_response.new? && !completed?
        'В ожидании ответа' 
      elsif !completed?
        link_to 'принять предложение', set_winner_sea_freight_path(self, sea_freight_response_id: sea_freight_response.id), method: :post, confirm: "Вы хотите выбрать победителя торгов - #{sea_freight_response.contractor.try(:title)}", class: 'choose-winner-link'
      end
    end
  end

  def link_or_auth
    if current_contractor.authorized?
      yield
    else
      link_to 'авторизуйтесь для выбора победителя', authorization_path
    end
  end

  def best_offline_label
    return 'Offline-предложение Клиента' if current_contractor.ved_contractor?
    'Offline-предложение'
  end

  def containers_amount
    transport_units.map(&:quantity).inject{|sum, x| sum + x }
  end

  def project_status
    return sea_freight_responses.by_contractor(current_contractor).state_string if current_contractor.ved_contractor?
    state_string
  end

  def project_link
    if new? || form?
      l = link_to(project_title, "/#{SeaFreight.name.underscore.pluralize}/" + id.to_s + '/build/' + (status || 'general_info'))
    else
      l = link_to(project_title, project_pth)
    end
    raw l
  end

  def project_pth
    self
  end

  def owner_or_ns?
    owner?(current_contractor) || current_contractor.ns?
  end

  def project_title
    "#{SeaFreight.model_name.human}: #{full_title}"
  end
end
