class TenderEndWorker
  include Sidekiq::Worker

  def perform(tender_id)
    Tender.find(tender_id).in_date_of_end
  end

  def self.delete_jobs_by_tender_id(tender_id)
    Sidekiq::ScheduledSet.new.each do |job|
      job.delete if job.klass == 'TenderEndWorker' && job.args.include?(tender_id)
    end
    if Rails.env.test?
      jobs = TenderEndWorker.jobs
      removed = jobs.detect{|job| job["args"].include?(tender_id)}
      jobs.delete(removed)
    end
  end
end