# encoding: utf-8
# Ved Requests Messages decorator. Parent for all messagable services
class VedRequestDecorator < MainDecorator
  delegate_all

  def header(i)
    content_tag :h2, class: header_classes(i) do
      arrows(i) + human_state(i)
    end
  end

  def human_state(i)
    t "statuses.#{type.underscore}.#{state_name_by_index(i)}"
  end

  def arrows(i)
    return '' unless after_state?(i)
    content_tag(:i, '', class: 'fa fa-chevron-up') + content_tag(:i, '', class: 'fa fa-chevron-down')
  end

  def after_state?(i)
    state_index >= i
  end

  def before_state?(i)
    !after_state?(i)
  end

  def that_state?(i)
    state_index == i
  end

  def state_index
    self.class.state_machine.states.map(&:name).index(state.to_sym)
  end

  def state_name_by_index(i)
    self.class.state_machine.states.to_a[i].name
  end

  def has_form?(st)
    current_state?(st) && !completed?
  end

  def header_classes(i)
    classes = ['ved_req_step']
    (classes << '_exp') if that_state?(i)
    classes << (before_state?(i) ? '_not-active' : 'js-accordion-trigger')
    classes
  end

  def next_step_link
    link_to('Следующий шаг', [:next_step, self], class: 'minor_button wide_button right', method: :put, confirm: 'Вы уверены, что хотите перейти на следующий шаг?') if next_step?
  end

  def states
    self.class.state_machine.states.map(&:name)
  end

  def next_step?
    !completed?
  end

  def step_explanation(i)
    content_tag :div, raw(t "explanations.#{type.underscore}.#{state_name_by_index(i)}"), class: 'explanation'
  end

  def messages_by_state(st)
    ved_messages.includes(:attachments).by_state(st.to_s)
  end
end
