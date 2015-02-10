# encoding: utf-8

class SeaFreightExecutionSeaRailway < SeaFreightExecution
  state_machine initial: :new do
    after_transition on: :complete, do: :end_project

    state :new
    state :step1
    state :step2_1
    state :step2_2
    state :step3
    state :step4_1
    state :step4_2
    state :completed

    after_transition on: :to_step1 do |sfe, transition|
      VedRequestMailer.next_step(sfe, [sfe.contractor]).deliver
    end

    after_transition on: :to_step2_1 do |sfe, transition|
      VedRequestMailer.next_step(sfe, [Contractor.ns, sfe.winner_contactor]).deliver
      sfe.inbox_payments.create(contractor_id: sfe.winner_contactor.id)
    end

    after_transition on: :to_step2_2 do |sfe, transition|
      VedRequestMailer.next_step(sfe, [sfe.contractor, sfe.winner_contactor]).deliver
      last_inbox = sfe.inbox_payments.last
      sfe.outbox_payments.create(contractor_id: sfe.contractor_id, sum: last_inbox.try(:sum), purpose: last_inbox.try(:purpose))
    end

    after_transition on: :to_step4_1 do |sfe, transition|
      VedRequestMailer.next_step(sfe, [Contractor.ns, sfe.winner_contactor]).deliver
    end

    after_transition on: [:to_step3, :to_step4_2, :completed] do |sfe, transition|
      VedRequestMailer.next_step(sfe, [sfe.contractor, sfe.winner_contactor]).deliver
    end

    state :new, :step1, :step3 do
      def next_step_contractor?(current_contractor)
        vedable.try(:winner).contractor == current_contractor
      end
    end

    state :step2_1, :step2_2, :step4_1, :step4_2 do
      def next_step_contractor?(current_contractor)
        Contractor.ns == current_contractor
      end
    end

    state :new, :step1, :step3 do
      def contractor_can_answer?(current_contractor)
        true
      end

      def receivers(sender)
        [(sender == vedable.contractor ? winner_contractor : vedable.contractor)]
      end
    end

    state :step2_2, :step4_2 do
      def contractor_can_answer?(current_contractor)
        (vedable.contractor_id == current_contractor.id) || current_contractor.ns?
      end

      def receivers(sender)
        [(sender == vedable.contractor ? Contractor.ns : vedable.contractor)]
      end
    end
    state :step2_1, :step4_1 do
      def contractor_can_answer?(current_contractor)
        (winner_contractor == current_contractor) || current_contractor.ns?
      end

      def receivers(sender)
        [(sender == winner_contractor ? Contractor.ns : winner_contractor)]
      end
    end
  #events
    event :to_step1 do
      transition new: :step1
    end
    event :to_step2_1 do
      transition step1: :step2_1
    end
    event :to_step2_2 do
      transition step2_1: :step2_2
    end
    event :to_step3 do
      transition step2_2: :step3
    end
    event :to_step4_1 do
      transition [:step2_2, :step3] => :step4_1
    end
    event :to_step4_2 do
      transition step4_1: :step4_2
    end
    event :complete do
      transition step4_2: :completed
    end
  end
  # end of state machine

  def to_next_step
    case state
    when 'new'
      self.to_step1
    when 'step1'
      self.to_step2_1
    when 'step2_1'
      self.to_step2_2
    when 'step2_2'
      self.to_step3
    when 'step3'
      self.to_step4_1
    when 'step4_1'
      self.to_step4_2
    else
      self.complete
    end
  end

end