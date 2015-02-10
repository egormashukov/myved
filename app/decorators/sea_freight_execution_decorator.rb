# encoding: utf-8

class SeaFreightExecutionDecorator < VedRequestDecorator
  delegate_all

  def next_step_link
    link_to('Следующий шаг', next_step_sea_freight_execution_path(self), class: 'minor_button wide_button right', method: :put, confirm: 'Вы уверены, что хотите перейти на следующий шаг?') if next_step?
  end

  def project_status
    human_state(state_index)
  end

  def project_link
    link_to(project_title, project_pth)
  end

  def project_pth
    sea_freight_execution_url(self)
  end

  def project_title
    "Исполнение торгов: #{vedable.try(:full_title)}"
  end

  def wait_decision?
    false
  end

  def form?
    false
  end

  def open_message_to_myved(winner)
    if owner?(current_contractor) || current_contractor.ved_contractor?
      link_to_messages(self, Contractor.ns, title = 'По техническии вопросам пишите сюда')
    elsif current_contractor.ns?
      myved_messages_links(winner)
    end
  end

  def myved_messages_links(winner)
    link_messages_btn(self, self.contractor, 'написать клиенту') + link_messages_btn(self, winner, 'написать КА')
  end

  def messages_by_state(st)
    if ['step2_1', 'step4_1'].include?(state) && owner?(current_contractor)
      []
    else
      ved_messages.includes(:attachments).by_state(st.to_s)
    end
  end
end
