class OutboxPayment < Payment
  state_machine initial: :new do

    state :new
    state :sent
    state :paid

    event :send_invoice do
      transition new: :sent
    end

    event :pay do
      transition [:new, :sent] => :paid
    end

    after_transition on: :send_invoice do |payment|
      payment.notifications.build(contractor_id: payment.contractor_id).set_body(:inbox_sent, payment)
    end

    after_transition on: :pay do |payment|
      payment.notifications.build(contractor_id: payment.contractor_id).set_body(:inbox_paid, payment)
    end
  end
end
