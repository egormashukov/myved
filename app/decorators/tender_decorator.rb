# encoding: utf-8

class TenderDecorator < Draper::Decorator
  include Draper::LazyHelpers
  include ActionView::Helpers::UrlHelper

  delegate_all

  def open_message_link
    if owner?(current_contractor)
      link_messages_btn(self, Contractor.ns, 'написать myVED')
    elsif current_contractor.ns?
      link_messages_btn(self, owner, 'написать клиенту')
    elsif current_contractor.supplier?
      supplier_messages_links
    end
  end

  def supplier_messages_links
    link_messages_btn(self, owner, 'написать клиенту') + link_messages_btn(self, Contractor.ns, 'написать myVED')
  end

  def project_status
    return current_state if owner?(current_contractor)
    supplier_status(current_contractor)
  end

  def project_link
    if new? || form?
      l = link_to(project_title, "/#{Tender.name.underscore.pluralize}/" + id.to_s + '/build/' + (status || 'general_info'))
    else
      l = link_to(project_title, project_pth)
    end
    raw l
  end

  def project_pth
    self
  end

  def project_title
    return subject unless current_contractor.supplier?
    owner.title + '. ' + subject
  end

  def end_date
    try(:end_at).presence || 'активный'
  end

  def wait_decision?
    active? && completed?
  end

  def your_response(current_contractor)
    return '' unless tender_responses.first_by_contractor(current_contractor).presence
    price_string(tender_responses.first_by_contractor(current_contractor).summ_cost, currency)
  end

  def winner
    return '' unless deal.supplier.presence
    raw "Победитель: #{link_to deal.supplier.title, deal.supplier}"
  end

  def control_panel(current_contractor)
    html = "<div class='actions'>"
    # html << (link_to t(:back), deals_path, class: 'minor_button')
    if deal.owner?(current_contractor) || current_contractor.ns?
      html << owner_panel(current_contractor)
    else
      html << participant_panel(current_contractor) unless completed?
    end
    html << '</div>'
    raw html
  end

  def owner_panel(current_contractor)
    return '' unless completed?
    if deal.cost_calculation.presence
      link_to CostCalculation.model_name.human, deal.cost_calculation, class: 'main_button right wide_button'
    elsif deal.successful?
      link_to(CostCalculation.model_name.human, cost_calculations_building_path(deal_id: deal.id), method: :post, class: 'main_button right wide_button')
    elsif deal.unsuccessful?
      ''
    else
      link_to(CostCalculation.model_name.human, cost_calculations_building_path(deal_id: deal.id), method: :post, class: 'main_button right wide_button') + link_to(t(:complete), [:complete_deal, deal], method: 'post', class: 'main_button right wide_button')
    end
  end

  def participant_panel(current_contractor)
    html = ''
    if answer_by(current_contractor).presence
      html << (link_to t(:update_response), edit_tender_tender_response_path(self, answer_by(current_contractor)), class: 'main_button wide_button')
    elsif tender_contractors.first_by_contractor(current_contractor).confirmed?
      html << decline_link(current_contractor, 'minor_button')
      html << respond_link('main_button right')
    elsif tender_contractors.first_by_contractor(current_contractor).not_decilned?
      html << decline_link(current_contractor, 'minor_button right')
      # html << confirm_link(current_contractor, 'main_button wide_button')
      html << respond_link('main_button')
    end
    raw html
  end

  def confirm_link(current_contractor, classes = '')
    link_to t(:confirm), confirm_tender_contractor_path(tender_contractors.first_by_contractor(current_contractor)), class: classes
  end

  def decline_link(current_contractor, classes = '')
    link_to t(:decline), project_contractors.first_by_contractor(current_contractor), method: :delete, class: classes, confirm: 'Точно отказаться от участия в тендере?'
  end

  def respond_link(classes = '')
    link_to t(:respond), new_tender_tender_response_path(self), class: classes
  end

  def summary_table_tr(&block)
    html = ''
    html << content_tag(:td, TenderResponse.human_attribute_name(:terms_of_payment))
    html << content_tag(:td, terms_of_payment)
    tender_responses.each do |tender_response|
      html << block
    end
    raw html
  end

  def chose_row(responses)
    return '' if completed?
    html = ''
    html << '<tr>'
    html << "<td> #{reject_all_link} </td>"
    html << '<td></td>'
    responses.each do |tender_response|
      html << content_tag(:td, button_to('выбрать', complete_tender_path(self, tender_response: tender_response.id), class: 'main_button chose_winner_button'))
    end
    if deal.owner?(current_contractor)
      tender_contractors.not_respond(tender_responses).each do |tc|
        html << content_tag(:td, tc.status_string)
      end
    end
    html << '</tr>'
    raw html
  end

  def empty_cells
    html = ''
    if deal.owner?(current_contractor)
      tender_contractors.not_respond(tender_responses).each do |tc|
        html << content_tag(:td, '')
      end
    end
    raw html
  end

  def om_service
    oem_service? ? 'oem service' : 'odm service'
  end

  def reject_all_link
    return '' if completed?
    button_to 'отказать всем', reject_all_tender_path(self), class: 'main_button'
  end

  def attr_or_bip(field, current_contractor)
    if current_contractor
      raw "#{content_tag(:i, '', class: 'fa fa-pencil')} #{best_in_place(self, field, type: 'textarea')}"
    else
      try(field)
    end
  end
end
