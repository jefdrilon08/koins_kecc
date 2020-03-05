class UserDemerit < ApplicationRecord
  include Rails.application.routes.url_helpers

  STATUSES  = ["pending", "approved"]

  DEMERIT_TYPES = [
    "verbal",
    "written",
    "written with warning of suspension",
    "suspension",
    "preventive suspension"
  ]

  belongs_to :user
  belongs_to :branch

  validates :status, presence: true, inclusion: { in: STATUSES }
  validates :date_prepared, presence: true
  validates :date_approved, presence: true, if: :approved?
  validates :date_of_action, presence: true
  validates :reason, presence: true
  validates :explanation, presence: true
  validates :demerit_type, presence: true, inclusion: { in: DEMERIT_TYPES }
  validates :role, presence: true

  validate :correct_file_mime_type
  validate :presence_of_file

  has_one_attached :file

  before_validation :load_defaults

  def file_url
    if self.file.attached?
      return rails_blob_path(self.file, disposition: "attachment", only_path: true)
    else
      ActionController::Base.helpers.asset_url("missing_file.png")
    end
  end

  def load_defaults
    if self.status.blank?
      self.status = 'pending'
    end

    if self.date_prepared.blank?
      self.date_prepared  = Date.today
    end
  end

  def pending?
    self.status == "pending"
  end

  def approved?
    self.status == "approved"
  end

  def to_s
    "#{self.date_of_action.strftime("%b %d, %Y")} - #{self.reason}"
  end

  private

  def correct_file_mime_type
    if file.attached? && !file.content_type.in?(%w(image/jpeg image/png))
      errors.add(:file, 'Must be a JPEG or PNG file')
    end
  end

  def presence_of_file
    if !file.attached?
      errors.add(:file, 'file attachment required')
    end
  end
end
