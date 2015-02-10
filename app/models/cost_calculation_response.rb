class CostCalculationResponse < ActiveRecord::Base
  attr_accessible :cost_calculation_id, :currency, :currency_transaction_comment, :currency_transactions_cost, :custom_duty_comment, :custom_duty_cost, :customs_cost, :customs_comment, :delivery_comment, :delivery_cost, :ns_outsourcing_comment, :ns_outsourcing_cost, :permits_comment, :permits_cost, :risks

  belongs_to :cost_calculation
  after_create :send_messages, :update_cost_calc_status

  def summ_cost
    fields = [:currency_transactions_cost, :custom_duty_cost, :customs_cost, :delivery_cost, :ns_outsourcing_cost, :permits_cost]
    summ = 0
    fields.each do |field|
      summ += self.try(field) if self.try(field)
    end
    summ
  end

private

  def update_cost_calc_status
    cost_calculation.answer
  end

  def send_messages
    cost_calculation.notifications.build(contractor_id: cost_calculation.contractor_id).set_body(:new_response)
  end
end

