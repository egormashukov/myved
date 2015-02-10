class ContractorDocument < Document
  attr_accessible :description
  validates_presence_of :title, :file_location
end
