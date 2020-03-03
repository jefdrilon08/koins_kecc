class AttachmentFile < ApplicationRecord
	include Rails.application.routes.url_helpers
	
	belongs_to :member

	has_one_attached :file

	validates :file_name, presence: true

	# def file_url
	# 	if self.file.attached? and self.file.representable?
 #      		return rails_blob_path(self.file, disposition: "attachment", only_path: true)
 #    	else
 #      		"http://#{ENV['HOST']}/#{ActionController::Base.helpers.asset_path('missing_file.png')}"
 #    	end
	# end
end
