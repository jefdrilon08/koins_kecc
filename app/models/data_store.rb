class DataStore < ApplicationRecord
  STATUSES = ["processing", "done", "error", "closed", "approved", "pending"]

  validates :meta, presence: true
  validates :data, presence: true
  validates :status, presence: true, inclusion: { in: STATUSES }

  scope :processing, -> { where(status: "processing") }
  scope :done, -> { where(status: "done") }
  scope :closed, -> { where(status: "closed") }
  scope :approved, -> { where(status: "approved") }
  scope :pending, -> { where(status: "pending") }

  scope :branch_loans_stats, -> { where("meta->>'data_store_type' = ?", "BRANCH_LOANS_STATS") }
  scope :branch_with_centers_loans_stats, -> { where("meta->>'data_store_type' = ?", "BRANCH_WITH_CENTERS_LOANS_STATS") }
  scope :balance_sheets, -> { where("meta->>'data_store_type' = ?", "BALANCE_SHEET") }
  scope :income_statements, -> { where("meta->>'data_store_type' = ?", "INCOME_STATEMENT") }
  scope :member_counts, -> { where("meta->>'data_store_type' = ?", "MEMBER_COUNTS") }
  scope :insurance_member_counts, -> { where("meta->>'data_store_type' = ?", "INSURANCE_MEMBER_COUNTS") }
  scope :claims_counts, -> { where("meta->>'data_store_type' = ?", "CLAIMS_COUNTS") }
  scope :branch_repayment_reports, -> { where("meta->>'data_store_type' = ?", "BRANCH_REPAYMENT_REPORT") }
  scope :year_end_closings, -> { where("meta->>'data_store_type' = ?", "YEAR_END_CLOSING") }
  scope :personal_funds, -> { where("meta->>'data_store_type' = ?", "PERSONAL_FUNDS") }
  scope :soa_funds, -> { where("meta->>'data_store_type' = ?", "SOA_FUNDS") }
  scope :soa_expenses, -> { where("meta->>'data_store_type' = ?", "SOA_EXPENSES") }
  scope :soa_loans, -> { where("meta->>'data_store_type' = ?", "SOA_LOANS") }
  scope :accounting_entries_summaries, -> { where("meta->>'data_store_type' = ?", "ACCOUNTING_ENTRIES_SUMMARY") }
  scope :watchlists, -> { where("meta->>'data_store_type' = ?", "WATCHLIST") }
  scope :repayment_rates, -> { where("meta->>'data_store_type' = ?", "REPAYMENT_RATES") }
  scope :monthly_new_and_resigned, -> { where("meta->>'data_store_type' = ?", "MONTHLY_NEW_AND_RESIGNED") }
  scope :x_weeks_to_pay,  -> { where("meta->>'data_store_type' = ?", "X_WEEKS_TO_PAY") }
  scope :monthly_incentives, -> { where("meta->>'data_store_type' = ?", "MONTHLY_INCENTIVE") }
  scope :dropout_rates, -> { where("meta->>'data_store_type' = ?", "DROPOUT_RATE") }
  scope :icpr, -> { where("meta->>'data_store_type' = ?", "ICPR") }
  scope :patronage_refund, -> { where("meta->>'data_store_type' = ?", "PATRONAGE_REFUND") }
  scope :manual_aging, -> { where("meta->>'data_store_type' = ?", "MANUAL_AGING") }
  scope :import_insurance_account_transactions, -> { where("meta->>'data_store_type' = ?", "IMPORT_INSURANCE_ACCOUNT_TRANSACTIONS") }
  scope :time_deposit_withdrawal, -> { where("meta->>'data_store_type' = ?", "TIME_DEPOSIT_WITHDRAWAL") }
  scope :time_deposit_autorenewal, -> { where("meta->>'data_store_type' = ?", "TIME_DEPOSIT_AUTORENEWAL") }
  scope :branch_resignations, -> { where("meta->>'data_store_type' = ?", "BRANCH_RESIGNATIONS") }

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

  def pending?
    self.status == "pending"
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

  def approved?
    self.status == "approved"
  end

end
