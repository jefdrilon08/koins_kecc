class DataStore < ApplicationRecord
  STATUSES = ["processing", "done", "error", "closed"]

  validates :meta, presence: true
  validates :data, presence: true
  validates :status, presence: true, inclusion: { in: STATUSES }

  scope :processing, -> { where(status: "processing") }
  scope :done, -> { where(status: "done") }
  scope :closed, -> { where(status: "closed") }

  scope :branch_loans_stats, -> { where("meta->>'data_store_type' = ?", "BRANCH_LOANS_STATS") }
  scope :branch_with_centers_loans_stats, -> { where("meta->>'data_store_type' = ?", "BRANCH_WITH_CENTERS_LOANS_STATS") }
  scope :member_counts, -> { where("meta->>'data_store_type' = ?", "MEMBER_COUNTS") }
  scope :branch_repayment_reports, -> { where("meta->>'data_store_type' = ?", "BRANCH_REPAYMENT_REPORT") }
  scope :year_end_closings, -> { where("meta->>'data_store_type' = ?", "YEAR_END_CLOSING") }
  scope :personal_funds, -> { where("meta->>'data_store_type' = ?", "PERSONAL_FUNDS") }
  scope :soa_funds, -> { where("meta->>'data_store_type' = ?", "SOA_FUNDS") }
  scope :soa_expenses, -> { where("meta->>'data_store_type' = ?", "SOA_EXPENSES") }
  scope :soa_loans, -> { where("meta->>'data_store_type' = ?", "SOA_LOANS") }
  scope :accounting_entries_summaries, -> { where("meta->>'data_store_type' = ?", "ACCOUNTING_ENTRIES_SUMMARY") }

  before_validation :load_defaults

  def load_defaults
    if self.new_record? && self.status.blank?
      self.status = "processing"
    end
  end

  def progress_as_percent
    if meta.present? and meta.with_indifferent_access[:progress].present?
      "#{meta.with_indifferent_access[:progress]}%"
    else
      "0%"
    end
  end

  def closed?
    self.status == "closed"
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
