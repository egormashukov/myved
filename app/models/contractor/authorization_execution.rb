# encoding: utf-8

class Contractor::AuthorizationExecution < VedRequest

  state_machine initial: :new do
    state :new
    state :completed

    after_transition on: [:to_step1, :complete] do |sfe|
      VedRequestMailer.next_step(sfe, [sfe.contractor]).deliver
    end

    event :complete do
      transition new: :completed
    end
  end

  def to_next_step
    case state
    when 'new'
      self.complete
    end
  end

  def mail_subject
    "Авторизация: #{contractor.title}"
  end

  def end_project
    project_contractors.not_ended.each do |pc|
      pc.update_attributes(end_at: Time.now)
    end
  end

  def self.for_myved_attention
    Contractor::AuthorizationExecution.joins(:ved_messages).where('state IN (?)', ['new', 'step1'])
  end
end
