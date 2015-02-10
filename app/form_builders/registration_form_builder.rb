class RegistrationFormBuilder < ActionView::Helpers::FormBuilder
  delegate :content_tag, :tag, :pluralize, :raw, :link_to, :image_tag, :t, to: :@template
  
  def text_field_inline(name, icon_title, *args)
    content_tag :div, class: 'reg_field' do
      content_tag(:div, '', class: "field_icon field_icon_#{icon_title}") + content_tag(:div, text_field(name, *args), class: "right blue_cornered")
    end
  end
  def email_field_inline(name, icon_title, *args)
    content_tag :div, class: 'reg_field' do
      content_tag(:div, '', class: "field_icon field_icon_#{icon_title}") + content_tag(:div, email_field(name, *args), class: "right blue_cornered")
    end
  end
  def password_field_inline(name, icon_title, *args)
    content_tag :div, class: 'reg_field' do
      content_tag(:div, '', class: "field_icon field_icon_#{icon_title}") + content_tag(:div, password_field(name, *args), class: "right blue_cornered")
    end
  end
end