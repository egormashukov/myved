class TenderCheckAnswersWorker
  include Sidekiq::Worker

  def perform(tender_id)
    Tender.find(tender_id).send_reminder_message_after_check_answers
  end
  
  def self.delete_jobs_by_tender_id(tender_id)
    Sidekiq::ScheduledSet.new.each do |job|
      job.delete if job.klass == 'TenderCheckAnswersWorker' && job.args.include?(tender_id)
    end
    if Rails.env.test?
      jobs = TenderCheckAnswersWorker.jobs
      removed = jobs.detect{|job| job["args"].include?(tender_id)}
      jobs.delete(removed)
    end
  end

  # @queue = :tenders_check_answers
  # def self.perform(tender_id)
  #   tender = Tender.find(tender_id)
  #   tender_responses = tender.tender_responses
  #   tender.tender_contractors.not_declined.each do |tender_contractor|
  #     unless tender_responses.select{|tr| tr.contractor_id == tender_contractor.contractor_id}.any?
  #       tender.send_reminder_to_participant(tender_contractor.contractor_id)
  #     end
  #   end
  # end
end