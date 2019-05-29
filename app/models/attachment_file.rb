class AttachmentFile < ApplicationRecord
	belongs_to :member

	has_one_attached :file

	validates :file_name, presence: true
end
