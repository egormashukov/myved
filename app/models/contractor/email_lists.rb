class Contractor::EmailLists < ActiveRecord::Base
  attr_accessible :contractor_id, :cost_calculation_list, :sea_freight_execution_list, :sea_freight_list, :tender_list

  belongs_to :contractor

  def emails_list(list_string)
    begin
      (try(list_string).gsub(/ /i, ',').gsub(/;/i, ',').gsub(/\\r\\/, ',').split(',').reject(&:blank?) + [contractor.email]).reject{|e| (e=~/.+@.+\..+/i).nil?}
    rescue
      [contractor.email]
    end
  end

  def for_notification(notification)
    notifiable_type = (notification.notifiable.respond_to?(:mailer_class) && notification.notifiable.mailer_class.presence) || (notification.notifiable.respond_to?(:type) && notification.notifiable.type) || notification.notifiable.class.name
    emails_list("#{notifiable_type.try(:underscore)}_list".to_sym)
  end

  def for_ved_request(ved_request)
    emails_list("#{ved_request.base_class.try(:underscore)}_list".to_sym)
  end
end
