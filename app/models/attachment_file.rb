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
  belongs_to :claim, optional: true

  has_one_attached :file

  validates :file_name, presence: true, inclusion: { in: NAMES }
end
