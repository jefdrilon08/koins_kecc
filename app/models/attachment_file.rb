class AttachmentFile < ApplicationRecord
  NAMES = [
    "BLIPFORM", 
    "BC", 
    "MC", 
    "ID", 
    "COHABITATION", 
    "OTHERFILE"
  ]

  belongs_to :member
  before_save :capitalized_file_name

  def capitalized_file_name
    self.file_name.upcase!
  end

  has_one_attached :file

  # validates :file_name, presence: true, inclusion: { in: NAMES }
end
