class Property < ProductProperty
  attr_accessible :strong, :obligatory
  
  scope :obligatory, -> {where(obligatory: true)}
end
