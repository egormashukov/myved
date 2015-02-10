module CostCalculationsHelper
  def cost_cals_response_string(cost_calc_response, cost, comment)
    if (cost_calc_response.try(cost).presence && cost_calc_response.try(cost) > 0) || cost_calc_response.try(comment).presence
      content_tag :div, class: 'string' do
        content_tag(:div, CostCalculationResponse.human_attribute_name(cost), class: 'third') + content_tag(:div, price_string(cost_calc_response.try(cost), cost_calc_response.cost_calculation.try(:currency)), class: 'third') + content_tag(:div, cost_calc_response.try(comment), class: 'third')
      end
    end
  end
  def cost_cals_response_row(cost_calc_response, cost, comment)
    if (cost_calc_response.try(cost).presence && cost_calc_response.try(cost) > 0) || cost_calc_response.try(comment).presence
      content_tag :tr do
        content_tag(:td, CostCalculationResponse.human_attribute_name(cost)) + content_tag(:td, price_string(cost_calc_response.try(cost), cost_calc_response.cost_calculation.try(:currency)), class: 'center') + content_tag(:td, cost_calc_response.try(comment))
      end
    end
  end
end
