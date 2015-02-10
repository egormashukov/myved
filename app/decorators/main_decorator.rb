# encoding: utf-8
# Main decorator. Parent for all front decorators in app
class MainDecorator < Draper::Decorator
  include Draper::LazyHelpers
  include ActionView::Helpers::UrlHelper

  def labeled_options_array(field, obj = self)
    field_row label(field), options_array(field, obj)
  end

  def labeled_date(field)
    field_row label(field), date_string(field)
  end

  def labeled_datetime(field)
    field_row label(field), datetime_string(field)
  end

  def date_string(field)
    try(field).strftime('%d.%m.%Y') if try(field).presence
  end

  def datetime_string(field)
    if try(field).try(:year) == Time.now.year
      format = '%H:%M, %d.%m'
    else
      format = '%H:%M, %d.%m.%Y'
    end
    try(field).strftime(format) if try(field).presence
  end

  def labeled_field(field, lbl = field)
    field_row label(lbl), try(field)
  end

  def labeled_row(field, lbl = field)
    table_row label(lbl), try(field)
  end

  def value_from_options(field)
    option(field) || try(field)
  end

  def dateable(field)
    try(field).strftime('%d.%m.%Y') if try(field).presence
  end

  def currency_options
    [['USD', 'usd'],
    ['euro', 'eur'],
    ['руб', 'rub']]
  end

  def field_row(label, content)
    return '' unless content.presence
    content_tag :div, class: 'string' do
      content_tag(:div, label, class: 'third') +
      content_tag(:div, content, class: 'two_thirds')
    end
  end

  def labeled_file(field, lbl = field)
    field_row label(lbl), file_link(field, try("#{field}_url"))
  end

  def file_link(field, pth, classes = '')
    return nil unless try(field).present?
    link_to pth, target: '_blank', class: "blue_link #{classes}" do
      raw "#{content_tag(:i, '', class: 'fa fa-file')} #{h.title_with_ext(field, pth)}"
    end
  end

  def options_array(field, obj)
    return nil unless try(field).present?
    obj.try(options_method(field)).select { |option| try(field).include?(option[1].to_s) }
    .map { |o| o[0] }.join(', ')
  end

  def from_option(field, klass)
    klass.try(options_method(field)).find { |sf| sf[1] == try(field) }.try(:first).presence
  end

  private

  def options_method(field)
    "#{field}_options".to_sym
  end

  def table_row(label, content)
    content_tag :tr do
      content_tag(:td, label, class: 't') + content_tag(:td, content)
    end
  end
end
