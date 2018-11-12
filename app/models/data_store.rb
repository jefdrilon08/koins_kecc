class DataStore < ApplicationRecord
  STATUSES = ["processing", "done"]

  validates :meta, presence: true
  validates :data, presence: true
  validates :status, presence: true, inclusion: { in: STATUSES }

  scope :processing, -> { where(status: "processing") }
  scope :done, -> { where(status: "done") }

  scope :branch_loans_stats, -> { where("meta->>'data_store_type' = ?", "BRANCH_LOANS_STATS") }
  scope :branch_with_centers_loans_stats, -> { where("meta->>'data_store_type' = ?", "BRANCH_WITH_CENTERS_LOANS_STATS") }

  before_validation :load_defaults

  def load_defaults
    if self.new_record? && self.status.blank?
      self.status = "processing"
    end
  end

  def processing?
    self.status == "processing"
  end

  def done?
    self.status == "done"
  end
end
