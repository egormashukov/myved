module HelpItemsHelper

  def h_buy_product(items)
    items.select { |hi| hi.category == 'buy_product' }
  end

  def h_ved_request(items)
    items.select { |hi| hi.category == 'ved_request' }
  end

  def h_ved_tender(items)
    items.select { |hi| hi.category == 'ved_tender' }
  end

  def h_sell_to_russia(items)
    items.select { |hi| hi.category == 'sell_to_russia' }
  end

  def h_door_to_door_russia(items)
    items.select { |hi| hi.category == 'door_to_door_russia' }
  end

  def h_all_for_world_trade(items)
    items.select { |hi| hi.category == 'all_for_world_trade' }
  end

end
