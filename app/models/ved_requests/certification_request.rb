# encoding: utf-8

class CertificationRequest < VedRequest
  def human_state
    I18n.t("statuses.certification_request.#{state}")
  end

  def title
    "Разрешительные документы \"#{ved_messages.try(:first).try(:title)}\""
  end
end
