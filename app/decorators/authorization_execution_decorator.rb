# encoding: utf-8

class Contractor::AuthorizationExecutionDecorator < VedRequestDecorator
  delegate_all

  def next_step?
    super && current_contractor.ns?
  end

  def project_status
    human_state(state_index)
  end

  def project_link
    link_to(project_title, project_pth)
  end

  def project_pth
    self
  end

  def project_title
    mail_subject
  end

  def wait_decision?
    false
  end

  def form?
    false
  end
end
