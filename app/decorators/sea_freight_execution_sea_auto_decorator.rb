class SeaFreightExecutionSeaAutoDecorator < SeaFreightExecutionDecorator
  delegate_all

  def has_form?(st)
    current_state?(st) && !completed? && contractor_can_answer?(current_contractor)
  end

  def next_step?
    super && (next_step_contractor?(current_contractor) || current_contractor.ns?)
  end
end
