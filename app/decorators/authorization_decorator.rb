# encoding: utf-8

class Contractor::AuthorizationDecorator < MainDecorator
  delegate_all

  def label(field)
    Contractor.human_attribute_name(field)
  end

  def project_status
    state_string
  end

  def project_link
    link_to(project_title, project_pth)
  end

  def project_pth
    if (active? || authorized?) && authorization_execution.present?
      contractor_authorization_execution_path(authorization_execution)
    elsif current_step?('general_info')
      authorization_path
    else
      "/contractor/authorizations/#{step}"
    end
  end

  def project_title
    Contractor::Authorization.model_name.human
  end

  def state_label
    content_tag :span, state_string, class: 'lk-label _blue'
  end

  def wait_decision?
    false
  end

  def country_string
    value_from_options :country
  end

  def direction_string
    value_from_options :direction
  end

  def option(field)
    from_option(field, Contractor::Authorization)
  end
end
