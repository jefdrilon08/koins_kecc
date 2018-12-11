class DataStore < ApplicationRecord
  STATUSES = ["processing", "done", "error"]

  validates :meta, presence: true
  validates :data, presence: true
  validates :status, presence: true, inclusion: { in: STATUSES }

  scope :processing, -> { where(status: "processing") }
  scope :done, -> { where(status: "done") }

  scope :branch_loans_stats, -> { where("meta->>'data_store_type' = ?", "BRANCH_LOANS_STATS") }
  scope :branch_with_centers_loans_stats, -> { where("meta->>'data_store_type' = ?", "BRANCH_WITH_CENTERS_LOANS_STATS") }
  scope :member_counts, -> { where("meta->>'data_store_type' = ?", "MEMBER_COUNTS") }
  scope :branch_repayment_reports, -> { where("meta->>'data_store_type' = ?", "BRANCH_REPAYMENT_REPORT") }

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

  def error?
    self.status == "error"
  end
end
