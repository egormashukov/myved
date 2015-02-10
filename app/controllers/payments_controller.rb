class PaymentsController < ApplicationController
  before_filter :authenticate_contractor!

  def index
    @page = Page.find_by_slug('finansy')
    @inbox_payments = current_contractor.inbox_payments.for_contractor
    @outbox_payments = current_contractor.outbox_payments.for_contractor
  end
end
