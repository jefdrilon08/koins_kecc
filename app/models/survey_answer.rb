class SurveyAnswer < ApplicationRecord
  STATUSES  = ["pending", "published"]
  belongs_to :survey

  validates :meta, presence: true
  validates :data, presence: true
  validates :status, presence: true, inclusion: { in: STATUSES }

  scope :pending, -> { where(status: "pending") }
  scope :published, -> { where(status: "published") }

  before_validation :load_defaults

  def load_defaults
    if self.status.blank?
      self.status = "pending"
    end
  end

  def pending?
    self.status == "pending"
  end

  def published?
    self.status == "published"
  end
end
