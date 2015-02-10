# encoding: utf-8

class CostCalculationExecution < VedRequest

  # state machine
  state_machine initial: :new do
    state :new
    state :completed

    after_transition on: [:to_step1, :complete] do |sfe|
      VedRequestMailer.next_step(sfe, [sfe.contractor]).deliver
    end

  #events
    event :complete do
      transition new: :completed
    end
  end
  # end of state machine

  def to_next_step
    case state
    when 'new'
      self.complete
    end
  end

  # def title
  #   "Торги ВЭД \"#{ved_messages.try(:first).try(:title)}\""
  # end

  def mail_subject
    "Расчёт себестоимости: #{vedable.title}"
  end
end

