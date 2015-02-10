# encoding: utf-8

class AdminFormBuilder < ActionView::Helpers::FormBuilder
  delegate :content_tag, :tag, :pluralize, :raw, :link_to, :image_tag, :t, to: :@template

  def error_messages
    if object.errors.any?
      content_tag :div, id: 'error_explanation' do
        content_tag(:h2, "#{t 'save_errors'}: #{object.errors.count}") + content_tag(:ul, raw(error_items))
      end
    end
  end

  def text_field_row(name, *args)
    content_tag :tr do
      content_tag(:th, label(name), class: "#{'required' if required?(name)}") + content_tag(:td, text_field(name, *args))
    end
  end

  def email_field_row(name, *args)
    content_tag :tr do
      content_tag(:th, label(name), class: "#{'required' if required?(name)}") + content_tag(:td,  email_field(name, *args))
    end
  end
  def text_field_inline(name, *args)
    content_tag :div, class: 'field' do
      content_tag(:div, label(name), class: 'third left') + content_tag(:div, text_field(name, *args) + required_text(name), class: "two_thirds right cornered #{required_class(name)}")
    end
  end
  def number_field_inline(name, *args)
    content_tag :div, class: 'field' do
      content_tag(:div, label(name), class: "#{'required' if required?(name)} third") + content_tag(:div, number_field(name, *args) + required_text(name), class: 'two_thirds')
    end
  end
  def field_with_cost_and_comment(cost, comment)
    content_tag :tr do
      content_tag(:th, label(cost)) + content_tag(:td, number_field(cost, step: "any")) + content_tag(:td, text_area(comment, rows: 2))
    end
  end
  def select_field_row(name, *args)
    content_tag :tr do
      content_tag(:th, label(name), class: "#{'required' if required?(name)}") + content_tag(:td, select(name, *args))
    end
  end

  def number_field_row(name, *args)
    content_tag :tr do
      content_tag(:th, label(name), class: "#{'required' if required?(name)}") + content_tag(:td, number_field(name, *args), class: 'not_wide')
    end
  end

  def text_area_row(name, *args)
    content_tag :tr do
      content_tag(:th, label(name), class: "#{'required' if required?(name)}") + content_tag(:td, text_area(name, *args))
    end
  end


  def file_field_row(name, *args)
    content_tag :tr do
      content_tag(:th, label(name), class: "#{'required' if required?(name)}") + content_tag(:td, file_field(name, *args))
    end
  end

  def redactor_field(name, *args)
    content_tag :tr do
      content_tag(:td, label(name) + content_tag(:br) + text_area(name, *args, class: 'redactor'), class: "#{'required' if required?(name)}, colspan: 2", colspan: 2)
    end
  end

  def check_box_row(name, *args)
    content_tag :tr do
      content_tag(:th, check_box(name, *args) + label(name), class: "#{'required' if required?(name)}", colspan: 2)
    end
  end
  def check_box_inline(name, *args)
    content_tag :div, class: 'field checkbox' do
      check_box(name, *args) + content_tag(:span, label(name))
    end
  end
  def image_field_with_preview(name, *args)
    image_field(name, *args) + image_itself(name)
  end

  def image_field_with_preview_inline(name, *args)
    image_field_inline(name, *args) + image_itself_inline(name)
  end

  def image_field(name, *args)
    img_cache = eval(":#{name.to_s}_cache")
    content_tag :tr do
      content_tag(:th, label(name), class: "#{'required' if required?(name)}") + content_tag(:td, file_field(name, *args) + hidden_field(img_cache))
    end
  end
  def image_field_inline(name, *args)
    img_cache = eval(":#{name.to_s}_cache")
    content_tag :div, class: 'field' do
      content_tag(:div, label(name), class: "third #{'required' if required?(name)}") + content_tag(:div, file_field(name, *args) + hidden_field(img_cache), class: 'two_thirds')
    end
  end
  def image_itself(name)
    img_pth = eval("object.#{name}_url(:thumb)")
    if object.try(name).presence
      content_tag :tr do
        content_tag(:th) + content_tag(:td, image_tag(img_pth))
      end
    end
  end
  def image_itself_inline(name)
    img_pth = eval("object.#{name}_url(:thumb)")
    if object.try(name).presence
      content_tag :div, class: 'field' do
        content_tag(:div, '', class: 'third') + content_tag(:div, image_tag(img_pth), class: 'two_thirds')
      end
    end
  end
  def submit_main
    content_tag :div, class: 'actions' do
      submit(t(:save)) + submit(t(:apply), name: 'apply')
    end
  end

  def destroy_field
    content_tag :div do
      hidden_field(:_destroy) + link_to('отменить', '#', class: 'remove_fields minor_button')
    end
  end
  
private

  def required?(name)
    a = []
    a << object.class.validators.select{|v| v.class.name.split('::').last == 'PresenceValidator'}.collect{|v| v.attributes}
    a.flatten.include?(name)
  end
  
  def required_text(name)
    content_tag(:div, t(:required), class: 'required_text') if required?(name)
  end

  def required_class(name)
    'required_field' if required?(name)
  end

  def error_items
    object.errors.full_messages.map{|msg| content_tag(:li, msg)}.join
  end
end