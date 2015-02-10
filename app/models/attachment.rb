require 'file_size_validator'
class Attachment < ActiveRecord::Base
  attr_accessible :attachable_id, :attachable_type, :title, :file_location, :file_location_cache, :category
  belongs_to :attachable, polymorphic: true
  mount_uploader :file_location, AttachmentsUploader

  validates_presence_of :file_location
  validates :file_location, file_size: { maximum: 10.megabytes.to_i }

  def full_title
    title.presence || file_location.file.filename
  end
end
