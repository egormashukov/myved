# encoding: utf-8
class Privacy < ActiveRecord::Base
  STI_TYPES = %w{GeneralRule ForwardingService}

  validates :type, inclusion: STI_TYPES
  validates :title, presence: true

  mount_uploader :file_location, AttachmentsUploader

  scope :by_created, -> { order('created_at') }
  attr_accessible :title, :type, :visible, :file_location

  def real_file_location
    "/uploads/privacy/file_location/#{self.id.to_s}/#{File.basename(self.file_location.to_s)}"
  end
end
