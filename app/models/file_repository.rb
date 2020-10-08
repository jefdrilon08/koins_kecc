class FileRepository < ApplicationRecord
  include Rails.application.routes.url_helpers

  FILE_TYPES = [
    "INSURANCE_ACCOUNT_TRANSACTIONS"
  ]

  validates :file_type, presence: true, inclusion: FILE_TYPES

  has_one_attached :file

  def file_url
    return rails_blob_path(self.file, disposition: "attachment", only_path: true)
  end

  def actual_url
    if file_type == "INSURANCE_ACCOUNT_TRANSACTIONS"
      return "#{ENV['BASE_URL']}/#{file_url}"
    else
      raise "Invalid file type #{file_type}"
    end
  end
end
