class SeaFreightExecutionSeaDecorator < SeaFreightExecutionDecorator
  delegate_all

  def has_form?(st)
    current_state?(st) && !completed? && contractor_can_answer?(current_contractor)
  end

  def next_step?
    super && (next_step_contractor?(current_contractor) || current_contractor.ns?)
  end

  def step_explanation(i)
    content_tag :div, raw(t "explanations.sea_freight_execution_sea_auto.#{state_name_by_index(i)}"), class: 'explanation'
  end
end
