class ClaimAttachmentFile < ApplicationRecord
  belongs_to :claim

  has_one_attached :file

  validates :file_name, presence: true
end
