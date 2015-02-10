class InboxPayment < Payment

  state_machine initial: :sent do
    state :new
    state :sent
    state :paid

    event :send_invoice do
      transition new: :sent
    end

    event :pay do
      transition [:new, :sent] => :paid
    end
    after_transition on: :pay do |payment|
      payment.notifications.build(contractor_id: payment.contractor_id).set_body(:inbox_paid, payment)
    end
  end
end
