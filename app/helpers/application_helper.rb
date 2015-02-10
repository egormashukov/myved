# encoding: utf-8

module ApplicationHelper

  def autorun_help(help)
    content_tag :div, class: 'js-autotriggered hidden' do
      help_item help
    end
  end

  def link_to_file(title, pth, classes='')
    link_to pth, target: '_blank', class: "blue_link #{classes}" do
      raw "#{content_tag(:i, '', class: 'fa fa-file')} #{title_with_ext(title, pth)}"
    end
  end

  def link_to_attachment(attachment, classes='')
    link_to_file(truncate(attachment.full_title, length: 10), attachment.file_location_url, classes)
  end

  def title_with_ext(title, url)
    if url.presence && url.split('/').try(:last).split(".").count > 1
      "#{title}.#{url.split(".").try(:last)}"
    else
      title
    end
  end

  def present(object, klass = nil)
    klass ||= "#{object.class}Presenter".constantize
    presenter = klass.new(object, self)
    yield presenter if block_given?
    presenter
  end

  def link_to_toggle_approve(tender_response)
    if tender_response.approved?
      'одобрено'
    else
      link_to 'одобрить', [:toggle_approved, :admin, tender_response]
    end
  end

  def price_string(price, currency)
    raw "#{currency}#{price}"
  end

  def toggle_link(first_text, second_text, dom_class, dom_id)
    link_to first_text, '#', class: "#{dom_class} toggle_link blue_link", 'data-show-text' => first_text, 'data-hide-text' => second_text, 'data-toggled-element' => dom_class, id: dom_id
  end

  def required_field
    content_tag(:div, t(:required), class:'required_text')
  end

  def link_to_remove_field
    link_to 'отменить', '#', class: 'remove_fields main_button'
  end

  def back_button(pth,  classes = '', *args)
    link_to t(:back), pth, *args, class: "minor_button #{classes}"
  end

  def current_step_string(current_step)
    case current_step.to_s
    when 'general_info'
      content_tag :div, content_tag(:div, 'Шаг 1'), class: 'panel_step step1'
    when 'conditions_of_supply'
      content_tag :div, content_tag(:div, 'Шаг 2'), class: 'panel_step step2'
    when 'products'
      content_tag :div, content_tag(:div, 'Шаг 2'), class: 'panel_step step2'
    when 'add_product_requests'
      content_tag :div, content_tag(:div, 'Шаг 3'), class: 'panel_step step3'
    when "final_cost_calculation"
      content_tag :div, content_tag(:div, 'Шаг 3'), class: 'panel_step step3'
    when 'final'
      content_tag :div, content_tag(:div, 'Шаг 4'), class: 'panel_step step4'
    else
      nil
    end
  end

  def two_colums_string(obj, name)
    if obj.try(name).presence
      content_tag :div, class: 'string' do
        content_tag(:div, obj.class.human_attribute_name(name), class: 'third') +
        content_tag(:div, obj.try(name), class: 'two_thirds')
      end
    end
  end

  def two_colums_row(obj, name)
    if obj.try(name).presence
      content_tag :tr do
        content_tag(:td, obj.class.human_attribute_name(name)) +
        content_tag(:td, obj.try(name), colspan: 2)
      end
    end
  end

  def product_field_or_bip(product, name)
    if product.cost_calculation.new?
      raw "#{content_tag(:i, '', class: 'fa fa-pencil')} #{best_in_place(product, name, path: [:bip_update, product])}"
    else
      product.try(name)
    end
  end

  def obj_field_or_bip(obj, name)
    if obj.transportable.new?
      raw "#{content_tag(:i, '', class: 'fa fa-pencil')} #{best_in_place(obj, name)}"
    else
      obj.try(name)
    end
  end

  def product_select_or_bip(product, name)
    if product.transportable.new?
      raw "#{content_tag(:i, '', class: 'fa fa-pencil')} #{best_in_place(product, name, :type => :select, :collection => TransportUnit.transport_options.collect{|key, value| value}.flatten.collect{|c| [c, c]})}"
    else
      product.try(name)
    end
  end

  def supplier_product_field_or_bip(product, ccp, name)
    if ccp.cost_calculation.new?
      raw "#{content_tag(:i, '', class: 'fa fa-pencil')} #{best_in_place(product, name)}"
    else
      product.try(name)
    end
  end

  def tr_header(header)
    content_tag :tr, content_tag(:td, content_tag(:h3, header), colspan: 2)
  end

  def help_item_link(help_item)
    visible_slides = help_item.help_slides.select(&:visible?)
    content_tag :li, class: "#{'soon' if help_item.soon?} #{'with_help' if visible_slides.present? && help_item.show_help?}" do
      raw "#{help_item_i(help_item) if visible_slides.present? && help_item.show_help?} #{link_to_help_i(help_item)}"
    end
  end

  def simple_help_item(help_item)
    link_to t(:privacy_policy), help_item.url, class: "blue_link", 'data-help-item-id' => help_item.id
  end

  def link_to_help_i(help_item)
    link_to raw(help_item.title), help_item.url, method: help_item.url_method, title: "#{t(:soon) if help_item.soon?}"
  end

  def help_item_i(help_item)
    content_tag(:i, '', class: 'fa fa-question-circle', 'data-help-item-id' => help_item.id, title: t("help_item"))
  end

  def plural_name(resource)
    t "#{resource}.plural", default: resource.singularize.camelize.constantize.model_name.human
  end

  def accusative_case(resource)
    t "#{resource}.accusative", default: resource.singularize.camelize.constantize.model_name.human
  end

  def action_accusative(resource, action)
    t(action) + " " + accusative_case(resource)
  end

  def selected_on(action = nil)
    a = controller.action_name
    'selected' if equality_for_active_on(action, a)
  end

  def equality_for_active_on(obj, subj)
    case
    when obj.class == Array
      obj.include?(subj)
    when obj.class == String
      subj == obj
    when obj.class == NilClass
      true
    end
  end

  def google_translate_link
    content_tag :div, google_translate_txt, class: 'google_translate'
  end

  def google_translate_txt
    raw t(:google_translate) + link_to(raw(" Google Translate" + image_tag('forms/google_translate_icon.png')), 'http://translate.google.ru/#ru/en/', target: '_blank', class: "blue_link")
  end

  def start_for_free_button(profile)
    link_to t(:start_for_free), new_contractor_registration_path(profile: profile), class: 'red_button most_wide_button centered upper'
  end

  def help_item(help_item)
    if help_item.presence
      content_tag(:i, '', class: 'help_item_icon fa fa-question-circle', 'data-help-item-id' => help_item.try(:id), title: t('help_item'))
    else
      ''
    end
  end

  def string_help_item(help_item)
    help_item.presence && link_to(help_item.category.camelize.constantize.human_attribute_name(help_item.title), '#', class: 'help_item_icon', 'data-help-item-id' => help_item.try(:id), title: t('help_item'))
  end

  def start_tour_link
    unless current_contractor.ved_contractor?
      if ca_names?('contractors', 'home')
        link_to start_tour_text, '#', class: 'start_tour tour_link', data: {step: 8, intro: tour_item('tour_link'), position: 'left', next: t('tour.next'), prev: t('tour.prev'), skip: t('tour.skip'), done: t('tour.done')}
      elsif ca_names?('tenders', 'show')
        link_to start_tour_text(t(:tender_tour)), '#', class: 'start_tour tour_link', data: {step: 5, intro: tour_item('tour_link'), position: 'left', next: t('tour.next'), prev: t('tour.prev'), skip: t('tour.skip'), done: t('tour.done')}
      end
    end
  end

  def start_tour_trigger
    if params['tour'].presence
      content_tag :div, '', id: 'start_tour_trigger'
    end
  end

  def start_tour_text(title = t(:site_tour))
    content_tag(:i, '', class: 'fa fa-lightbulb-o') + ' ' + title
  end

  def ca_names?(contr_name, act_name)
    controller.controller_name == contr_name && controller.action_name == act_name
  end
  def to_supplier_archive_link(deal)
    if deal.completed? || deal.try(:tender).try(:completed?)
      if deal.supplier_archive?
        link_to(t('actions.show_on_main'), [:toggle_supplier_archive, deal], method: 'put')
      else
        link_to(t('actions.remove_from_main'), [:toggle_supplier_archive, deal], method: 'put')
      end
    end
  end
  def to_archive_link(deal)
    if deal.completed? || deal.try(:tender).try(:completed?) || deal.try(:cost_calculation).try(:completed?)
      if deal.archive?
        link_to(t('actions.show_on_main'), [:toggle_archive, deal], method: 'put')
      else
        link_to(t('actions.remove_from_main'), [:toggle_archive, deal], method: 'put')
      end
    end
  end

  def decide_link(deal)
    if !deal.completed? && (deal.try(:tender).try(:active?) || deal.try(:cost_calculation).try(:answered?))
      link_to t('actions.decide'), (deal.try(:cost_calculation) || deal.try(:tender))
    end
  end
  def tour_item(title)
    t("tour.#{current_contractor.profile_short_title}.#{title}")
  end
  def tender_response_info_panel
    content_tag :div, class: 'google_translate _list' do
      content_tag :ul do
        content_tag(:li, google_translate_txt) + content_tag(:li, tender_privacy_policy)
      end
    end
  end

  def tender_privacy_policy
    string_help_item(HelpItem.where(category: 'page', title: 'tender_privacy_policy').first)
  end

  def ved_info_panel
    content_tag :div, class: 'google_translate _list' do
      content_tag :ul do
        content_tag(:li, ved_privacy_policy, class: "#{'run_privacy' if params[:privacy_policy].presence}") + content_tag(:li, ved_tender_info, class: "#{'run_info' if params[:ved_tender_info].presence}")
      end
    end
  end

  def ved_privacy_policy
    string_help_item(HelpItem.where(category: 'page', title: 'ved_privacy_policy').first)
  end

  def ved_tender_info
    string_help_item(HelpItem.where(category: 'page', title: 'ved_tender_info').first)
  end
end
