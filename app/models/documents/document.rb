require 'file_size_validator'
class Document < ActiveRecord::Base
  mount_uploader :file_location, AttachmentsUploader

  attr_accessible :contractor_id, :file_location, :title, :type, :file_location_cache
  validates_presence_of :contractor_id, :file_location
  validates :file_location, file_size: { maximum: 10.megabytes.to_i }
  belongs_to :contractor

  def full_title
    title.presence || file_location.file.try(:filename)
  end
end
