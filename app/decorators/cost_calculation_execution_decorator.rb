# encoding: utf-8

class CostCalculationExecutionDecorator < VedRequestDecorator
  delegate_all

  # def form?
  #   current_state?(state) && !completed? && contractor_can_answer?(current_contractor)
  # end

  def next_step?
    super && current_contractor.ns?
  end
end
