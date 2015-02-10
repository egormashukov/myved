# encoding: utf-8

class VedRequest < ActiveRecord::Base
  attr_accessible :contractor_id, :ved_messages_attributes, :paid, :archived, :bill

  belongs_to :contractor
  has_many :project_contractors, as: :projectable, dependent: :destroy

  has_many :ved_messages, dependent: :destroy
  has_many :messages, as: :messagable, dependent: :destroy

  belongs_to :vedable, polymorphic: true

  accepts_nested_attributes_for :ved_messages, allow_destroy: true

  def base_class
    type
  end

  def to_next_step
    case state
    when 'new'
      self.to_step1
    when 'step1'
      self.to_step2
    when 'step2'
      self.to_step3
    else
      self.complete
    end
  end

  def owner?(current_contractor)
    current_contractor.id == contractor_id
  end

  def current_state?(s)
    state.to_s == s.to_s
  end

  def pay_status
    paid? ? 'оплачено' : 'нет оплаты'
  end

  def receivers(sender)
    [(sender.ns? ? contractor : Contractor.ns)]
  end

  def mail_subject
    ved_messages.first.try(:title)
  end

  def human_state
    I18n.t("statuses.#{type.underscore}.#{state}")
  end
end
