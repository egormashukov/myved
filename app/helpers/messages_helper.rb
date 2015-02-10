# encoding: utf-8
module MessagesHelper
  def link_to_messages(messagable, contractor, title = 'написать')
    link_to '#', class: 'js-open-messages-link not-read-msgs-link', data: { 'messagable-type' => "#{messagable.class.model_name.underscore}_id", 'messagable-id' => messagable.id, 'contractor-id' => contractor.id } do
      raw(content_tag(:i, '', class: 'fa fa-envelope') + messages_count_wr(messagable, contractor) + " #{title}")
    end
  end

  def link_messages_btn(messagable, contractor, title = 'написать')
    link_to '#', class: 'js-open-messages-link', data: { 'messagable-type' => "#{messagable.class.model_name.underscore}_id", 'messagable-id' => messagable.id, 'contractor-id' => contractor.id } do
      raw("#{content_tag(:i, '', class: 'fa fa-envelope')} #{title} #{messages_count_btn_wr(messagable, contractor)}")
    end
  end

  def messages_count_btn_wr(messagable, contractor)
    c = messages_count(messagable, contractor)
    return '' if c == 0
    "(#{c})"
  end

  def messages_count_wr(messagable, contractor)
    c = messages_count(messagable, contractor)
    return '' if c == 0
    content_tag(:span, c, class: 'not-read-msgs')
  end

  def messages_count(messagable, contractor)
    messagable.messages.dialogue(current_contractor, contractor).to_current_contractor(current_contractor).not_read.count
  end
end
