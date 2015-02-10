# encoding: utf-8
class ProjectContractor < ActiveRecord::Base
  attr_accessible :contractor_id, :projectable_id, :projectable_type, :state, :end_at

  belongs_to :projectable, polymorphic: true
  belongs_to :contractor, inverse_of: :project_contractors

  scope :not_this, ->(company) { where(ProjectContractor.arel_table[:contractor_id].not_eq(company.id)) }
  scope :visible, -> { where(state: 'current') }
  scope :not_ended, -> { where(end_at: nil) }

  scope :quotations, -> { where('projectable_type IN (?)', ['SeaFreight', 'Tender', 'CostCalculation']) }
  scope :executions, -> { where('projectable_type IN (?)', ['VedRequest', 'Contractor::Authorization']) }

  after_create :set_owner

  state_machine initial: :new do

    state :new
    state :current
    state :archived

    event :to_current do
      transition new: :current
    end
    event :archive do
      transition current: :archived
    end
    event :to_current do
      transition archived: :current
    end
  end

  def toggle_archive
    archived? ? self.to_current : self.archive
  end

  # begin GOVNOCODE

  def self.not_respond(tender_responses)
    scoped.select{|tc| tender_responses.reject{|tr| ['new', 'waiting'].include?(tr.state)}.collect(&:contractor_id).exclude?(tc.contractor_id)}
  end

  def status_string
    'нет ответа'
  end

  def confirmed?
    !archived?
  end

  def self.first_by_contractor(current_contractor)
    scoped.select{|tr| tr.contractor_id == current_contractor.id}.first
  end

  # def projectable_type=(sType)
  #   super(sType.to_s.classify.constantize.base_class.to_s)
  # end
  # end GOVNOCODE

  private

  def set_owner
    return '' unless projectable.owner?(contractor)
    self.to_current
  end
end
