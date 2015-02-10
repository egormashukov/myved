# encoding: utf-8

class NotificationDecorator < MainDecorator
  delegate_all

  def full_title
    "#{notifiable.class.model_name.human}. #{title}"
  end

  def full_body
    content_tag :div, class: 'redactor-txt' do
      raw body
    end
  end

  def label(field)
    Notification.human_attribute_name(field)
  end
end
