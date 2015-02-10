# encoding: utf-8

class MainFormBuilder < ActionView::Helpers::FormBuilder
  delegate :content_tag, :tag, :pluralize, :raw, :link_to, :image_tag, :strip_tags, :t, :current_contractor, :options_for_select, to: :@template

  def error_messages
    return '' unless object.errors.any?
    content_tag :div, class: 'error_messages' do
      content_tag(:h2, t('activerecord.errors.template.header.other', model: object.class.model_name.human)) + content_tag(:ul, raw(error_items))
    end
  end

  def text_field_inline(name, *args)
    field_inline name, field_cornered(text_field name, placeholdered_args(name, *args))
  end

  def text_field_cornered(name, *args)
    form_field name, field_cornered(text_field name, placeholdered_args(name, *args))
  end

  def email_field_inline(name, *args)
    field_inline name, field_cornered(email_field name, placeholdered_args(name, *args))
  end

  def password_field_inline(name, *args)
    field_inline name, field_cornered(password_field name, placeholdered_args(name, *args))
  end

  def text_field_inline_with_value(name, value, *args)
    text_field_inline name, args_with_value(name, value, *args)
  end

  def text_field_with_value(name, value, *args)
    text_field name, args_with_value(name, value, *args)
  end

  def number_field_inline(name, *args)
    field_inline name, number_field(name, placeholdered_args(name, *args))
  end

  def select_inline(name, *args)
    field_inline name, select(name, *args)
  end

  def select_currency(name, classes = '')
    select(name, currency_options, {}, class: "selectto #{classes}")
  end

  def select_vat(name, classes = '')
    select(name, [['без НДС', '0'], ['НДС 18%', '18']], {}, class: "selectto #{classes}")
  end

  def select2_inline(name, options, classes = '')
    field_inline name, select(name, options, {}, class: "selectto #{classes}")
  end

  def text_area_inline(name, *args)
    field_vertical name, text_area(name, placeholdered_args(name, args_with_class(*args, 'autosize')))
  end

  def redactor(name)
    field_vertical name, text_area(name, class: 'redactor')
  end

  def date_select_inline(name, *args)
    field_inline name, date_select(name, *args)
  end

  def check_box_inline(name, *args)
    content_tag :div, class: 'field checkbox' do
      check_box(name, *args) + content_tag(:span, label_with_help(name))
    end
  end

  def number_field_with_value(name, value, *args)
    number_field name, args_with_value(name, value, *args)
  end

  def short_text_field_with_value(name, value, *args)
    short_text_field name, args_with_value(name, value, *args)
  end

  def text_field_with_value_custom(name, value, custom_required_txt, *args)
    text_field_inline_custom name, args_with_value(name, value, *args), custom_required_txt
  end

  def field_inline(name, form_input)
    fielded do
      content_tag(:div, label_with_help(name), class: %w(third left)) +
      content_tag(:div, form_field(name, form_input), class: field_classes(name))
    end
  end

  def field_vertical(name, form_input)
    fielded do
      label_with_help(name) + form_field(name, form_input)
    end
  end

  def fielded
    content_tag :div, class: 'field' do
      yield
    end
  end

  def main_button(name, html_class = 'main_button')
    submit name, class: "#{html_class} wide_button right"
  end

  def form_field(name, form_input)
    form_input + required_text(name) + caption(name) + error(name)
  end

  ############### NOT REFACTORED ZONE ####################

  def text_field_inline_custom(name, *args, custom_required_txt)
    content_tag :div, class: 'field' do
      content_tag(:div, label_with_help(name), class: 'third left') + content_tag(:div, text_field(name, placeholdered_args(name, *args)) + custom_required_text(custom_required_txt), class: field_classes(name, ['cornered']))
    end
  end

  def field_cornered(form_input)
    content_tag :div, form_input, class: 'cornered'
  end

  def short_text_field(name, *args)
    content_tag :div, text_field(name, placeholdered_args(name, *args)), class: 'cornered short_field'
  end

  def select_with_label(name, *args)
    content_tag :div, class: 'field' do
      content_tag(:div, label_with_help(name), class: 'third left') + content_tag(:div, select(name, *args) + required_text(name), class: field_classes(name))
    end
  end

  def select_inline_wide(name, *args)
    content_tag :div, class: 'field' do
      content_tag(:div, label_with_help(name), class: 'third left') + content_tag(:div, select(name, *args), class: field_classes(name))
    end
  end

  def file_field_inline_captioned(name)
    content_tag :fieldset do
      file_field_inline(name) + file_caption(name)
    end
  end

  def file_field_inline(name)
    content_tag :div, class: 'field' do
      content_tag(:div, label(name), class: 'half') +
      content_tag(:div, file_field_as_button(name) + hidden_field("#{name}_cache".to_sym), class: 'half right')
    end
  end

  def file_caption(name)
    content_tag :div, class: 'field' do
      content_tag(:div, t(:file_name), class: 'half caption') +
      content_tag(:div, (object.try("#{name}_url".to_sym).split('/').last if object.try("#{name}_url".to_sym)), class: 'right half file_location')
    end
  end

  def file_field_as_button(name, *args)
    content_tag :div, class: 'left file_field_as_button', data: { notice: t('file_chosing_notice') } do
      file_field(name, *args) + content_tag(:div, t(:load_file))
    end
  end

  def submit_or_send(step)
    content_tag :div, class: 'actions' do
      if step.to_s == 'final'
        main_button t(:send)
      else
        main_button t(:save_and_continue)
      end
    end
  end

  def select_multiple_contractors(contractors)
    content_tag :div, class: 'field' do
      content_tag(:div, (content_tag(:div, 'добавить из контактов', class: 'bold') + content_tag(:div, t(:contractors), class: 'italic light_text')), class: 'half left') + content_tag(:div, select(:contractor_ids, contractors, {}, multiple: true, class: 'multiselect'), class: 'half right')
    end
  end

  def image_field
    content_tag :div, class: 'field' do
      image_itself
    end
  end

  def image_itself
    html = ''
    if object.image_url(:icon)
      html << image_tag(object.image_url(:icon), class: 'form_image')
    end
    html << content_tag(:div, label(:image), class: 'left third')
    html << content_tag(:div, file_field(:image), class: 'right two_thirds')
    html << content_tag(:div, '', class: 'clear')
    html << hidden_field(:image_cache)
    raw html
  end

  def destroy_field
    content_tag :div do
      hidden_field(:_destroy) + link_to(raw(content_tag(:i, '', class: 'fa fa-trash-o') + ' ' + t(:remove_fieldset)), '#', class: 'remove_fields destroy_link')
    end
  end

  def help_item(name)
    item = HelpItem.by_category_n_title(object.class.name.underscore, name)
    return '' unless item.presence
    content_tag(:i, '', class: help_item_classes, 'data-help-item-id' => item.try(:id), title: t('help_item'))
  end

  def help_item_classes
    %w(help_item_icon fa fa-question-circle)
  end

  def label_with_help(name)
    raw(help_item(name) + label(name))
  end

  def placeholdered_args(name, *args)
    ags = args.extract_options!
    ph = ags[:placeholder].presence || placeholder(name)
    ags.merge!(placeholder: ph)
  end

  def status_date(name)
    val = object.try(name).presence ? object.try(name).strftime('%d.%m.%Y') : ''
    if current_contractor.ved_contractor? || current_contractor.ns?
      text_field(name, placeholder: '2014-12-30 (ГГГГ-ММ-ДД)', class: 'datepicker js-autosate')
    else
      val
    end
  end

  ############### REFACTORED ZONE ####################

  def field_classes(name, custom_classes=[])
    ['two_thirds', 'right', required_class(name)] + custom_classes
  end

  def error(name)
    content_tag :div, object.errors[name].join(', '), class: 'lk-form__error-txt'
  end

  def placeholder(name)
    strip_tags(t("placeholders.#{object.class.name.underscore}.#{name}"))
  end

  private

  def required?(name)
    a = []
    a << (object.class.validators.select { |v| v.class.name.split('::').last == 'PresenceValidator' }.map(&:attributes))
    a.flatten.include?(name)
  end

  def required_text(name)
    content_tag(:div, t(:required), class: 'required_text') if required?(name)
  end

  def custom_required_text(txt)
    content_tag(:div, txt, class: 'required_text')
  end

  def required_class(name)
    'required_field' if required?(name)
  end

  def error_items
    object.errors.full_messages.map{|msg| content_tag(:li, msg)}.join
  end

  def caption(name)
    txt = I18n.t "captions.#{object.class.name.underscore}.#{name}", default: ''
    return '' if txt.present?
    content_tag :div, txt, class: 'lk-form__caption'
  end

  def get_option(*args, name)
    args.extract_options![name]
  end

  def args_with_value(name, value, *args)
    options = args.extract_options!
    options.merge!(value: value.try(name)) if value.try(name)
    options
  end

  def args_with_class(*args, klass)
    default_options = args.extract_options!
    class_from_args = default_options[:class]
    default_options.merge!(class: "#{klass} #{class_from_args}")
  end

  def currency_options
    [['USD', 'usd'],
    ['euro', 'eur'],
    ['руб', 'rub']]
  end
end
