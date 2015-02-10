module DealsHelper
  def transaction_class(t, deal_transactions)
    'completed_transaction' if deal_transactions.select{|dt| dt.transaction_type == t.keys[0].to_s && dt.completed == true }.any?
  end
  
end
