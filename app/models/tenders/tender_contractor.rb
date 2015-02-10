# encoding: utf-8
class TenderContractor < ActiveRecord::Base
  attr_accessible :contractor_id, :tender_id, :confirmed
  attr_readonly :contractor_id, :tender_id

  belongs_to :contractor
  belongs_to :tender

  scope :not_declined, -> { where('confirmed = ? OR confirmed = ?', nil, true) }

  after_create :check_uniqueness

  def self.first_by_contractor(current_contractor)
    scoped.select{ |tr| tr.contractor_id == current_contractor.id }.first
  end

  def not_decilned?
    confirmed != false
  end

  def status_string
    if confirmed?
      'подтвердил участие'
    elsif confirmed == false
      'отказался от участия'
    else
      'ждем ответа'
    end
  end

  def self.not_respond(tender_responses)
    scoped.select{ |tc| tender_responses.reject{ |tr| ['new', 'waiting'].include?(tr.state) }.collect(&:contractor_id).exclude?(tc.contractor_id)}
  end

  private

  def check_uniqueness
    tender_contractors = TenderContractor.where('contractor_id = ? AND tender_id = ?', contractor_id, tender_id)
    if tender_contractors.size > 1
      tender_contractors.last.destroy
    end
  end
end
