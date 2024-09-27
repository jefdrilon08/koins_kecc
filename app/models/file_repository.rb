class FileRepository < ApplicationRecord
  include Rails.application.routes.url_helpers

  FILE_TYPES = [
    "MEMBERS",
    "BENEFICIARIES",
    "LEGAL_DEPENDENTS",
    "MEMBER_ACCOUNTS",
    "ACCOUNT_TRANSACTIONS",
    "CENTERS",
    "ADMIN_ADDRESS"
  ]

  validates :file_type, presence: true, inclusion: FILE_TYPES

  has_one_attached :file

  def file_url
    return rails_blob_path(self.file, disposition: "attachment", only_path: true)
  end

  def actual_url
    if file_type == "ACCOUNT_TRANSACTIONS" || file_type == "MEMBERS" || file_type == "LEGAL_DEPENDENTS" || file_type == "BENEFICIARIES" || file_type == "MEMBER_ACCOUNTS" || file_type == "CENTERS" || file_type == "ADMIN_ADDRESS"
      return "#{ENV['BASE_URL']}/#{file_url}"
    else
      raise "Invalid file type #{file_type}"
    end
  end
end
