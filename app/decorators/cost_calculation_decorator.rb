# encoding: utf-8

class CostCalculationDecorator < MainDecorator
  delegate_all

  def project_status
    current_state
  end

  def project_link
    if new? || form?
      l = link_to(project_title, "/#{CostCalculation.name.underscore.pluralize}/" + id.to_s + '/build/' + (status || 'general_info'))
    else
      l = link_to(project_title, project_pth)
    end
    raw l
  end

  def project_pth
    cost_calculation_execution
  end

  def project_title
    CostCalculation.model_name.human + ': ' + (try(:title) || I18n.t(:no_title))
  end

  def end_date
    'активный'
  end
  
  def wait_decision?
    answered?
  end


end
