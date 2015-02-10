# encoding: utf-8

class SeaFreightExecution < VedRequest
  after_create :add_sea_freight_execution_status, :add_project
  has_one :sea_freight_execution_status
  has_many :inbox_payments, as: :paidable
  has_many :outbox_payments, as: :paidable

  belongs_to :general_rule
  belongs_to :forwarding_service

  # state machine

  def base_class
    'SeaFreightExecution'
  end

  def human_state
    I18n.t("statuses.#{type.underscore}.#{state}")
  end

  def title
    "Торги ВЭД \"#{ved_messages.try(:first).try(:title)}\""
  end

  def winner_contactor
    vedable.winner.contractor
  end

  def mail_subject
    "Исполнение: #{vedable.full_title}"
  end

  def subject
    "Исполнение: #{vedable.full_title}"
  end

  def winner_contractor
    vedable.try(:winner).contractor
  end

  def general_rule_file
    self.general_rule.try(:file_location).to_s
  end

  def forwarding_service_file
    self.forwarding_service.try(:file_location).to_s
  end

  private

  def add_project
    [contractor, vedable.winner.contractor].each do |c|
      project_contractors.create(contractor_id: c.id).to_current
    end
  end

  def end_project
    project_contractors.not_ended.each do |pc|
      pc.update_attributes(end_at: Time.now)
    end
  end

  def add_sea_freight_execution_status
    create_sea_freight_execution_status
  end
end
