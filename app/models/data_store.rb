class DataStore < ApplicationRecord
  include Rails.application.routes.url_helpers

  STATUSES = [
    "processing",
    "done",
    "error",
    "closed",
    "approved",
    "pending",
    "for_printing",
    "checked"
  ]

  validates :meta, presence: true
  #validates :data, presence: true
  validates :status, presence: true, inclusion: { in: STATUSES }

  scope :processing, -> { where(status: "processing") }
  scope :done, -> { where(status: "done") }
  scope :closed, -> { where(status: "closed") }
  scope :approved, -> { where(status: "approved") }
  scope :pending, -> { where(status: "pending") }
  scope :error, -> { where(status: "error") }

  scope :branch_loans_stats, -> { where("meta->>'data_store_type' = ?", "BRANCH_LOANS_STATS") }
  scope :branch_with_centers_loans_stats, -> { where("meta->>'data_store_type' = ?", "BRANCH_WITH_CENTERS_LOANS_STATS") }
  scope :balance_sheets, -> { where("meta->>'data_store_type' = ?", "BALANCE_SHEET") }
  scope :trial_balances, -> { where("meta->>'data_store_type' = ?", "TRIAL_BALANCE") }
  scope :income_statements, -> { where("meta->>'data_store_type' = ?", "INCOME_STATEMENT") }
  scope :member_counts, -> { where("meta->>'data_store_type' = ?", "MEMBER_COUNTS") }
  scope :insurance_member_counts, -> { where("meta->>'data_store_type' = ?", "INSURANCE_MEMBER_COUNTS") }
  scope :member_quarterly_reports, -> { where("meta->>'data_store_type' = ?", "MEMBER QUARTERLY REPORTS") }
  scope :claims_counts, -> { where("meta->>'data_store_type' = ?", "CLAIMS_COUNTS") }
  scope :uploaded_documents_counts, -> { where("meta->>'data_store_type' = ?", "UPLOADED_DOCUMENTS_COUNTS") }
  scope :branch_repayment_reports, -> { where("meta->>'data_store_type' = ?", "BRANCH_REPAYMENT_REPORT") }
  scope :year_end_closings, -> { where("meta->>'data_store_type' = ?", "YEAR_END_CLOSING") }
  scope :personal_funds, -> { where("meta->>'data_store_type' = ?", "PERSONAL_FUNDS") }
  scope :soa_funds, -> { where("meta->>'data_store_type' = ?", "SOA_FUNDS") }
  scope :soa_expenses, -> { where("meta->>'data_store_type' = ?", "SOA_EXPENSES") }
  scope :soa_loans, -> { where("meta->>'data_store_type' = ?", "SOA_LOANS") }
  scope :accounting_entries_summaries, -> { where("meta->>'data_store_type' = ?", "ACCOUNTING_ENTRIES_SUMMARY") }
  #scope :watchlists, -> { where("meta->>'data_store_type' = ?", "WATCHLIST") }
  scope :watchlists, -> { where("meta->>'data_store_type' = ?", "REPAYMENT_RATES") }  # USE REPAYMENT_RATES FOR WATCHLIST
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
  scope :general_ledgers, -> { where("meta->>'data_store_type' = ?", "GENERAL_LEDGER") }
  scope :members_in_good_standing, -> {where("meta->> 'data_store_type' = ?", "MEMBERS_IN_GOOD_STANDING")}
  scope :for_writeoff, ->{where("meta->>'data_store_type' = ? ", "FOR_WRITEOFF")}
  scope :billing_for_writeoff, ->{where("meta->>'data_store_type' = ?","BILLING_FOR_WRITEOFF")}
  scope :insurance_personal_funds, -> { where("meta->>'data_store_type' = ?", "INSURANCE_PERSONAL_FUNDS") }
  scope :billing_for_writeoff_collections, ->{where("meta->>'data_store_type' = ?","BILLING_FOR_WRITEOFF_COLLECTION")}
  scope :additional_share, ->{where("meta->>'data_store_type' = ?","ADDITIONAL_SHARE")}
  scope :mbs_transfer, ->{where("meta->>'data_store_type' = ?","MBS_TRANSFER")}

  scope :share_capital_summary, ->{where("meta->>'data_store_type' = ?","SHARE_CAPITAL_SUMMARY")}
  scope :involuntary_members, -> {where("meta->>'data_store_type' =? ","INVOLUNTARY_MEMBERS")}
  scope :assets_liabilities, -> {where("meta->>'data_store_type' = ?","ASSETS_LIABILITIES")}
  scope :branch_cash_flow, -> {where("meta->>'data_store_type' =? ","branch_cash_flow")}
  scope :share_capital_involuntary, -> {where("meta->>'data_store_type' = ? ","SHARE_CAPITAL_INVOLUNTARY")}
  scope :billing_for_involuntary, -> {where("meta->>'data_store_type' = ? ","BILLING_FOR_INVOLUNTARY")}
  scope :member_per_center_counts, -> { where("meta->>'data_store_type' = ?", "MEMBER PER CENTER COUNTS") }
  scope :allowance_computation_report, -> { where("meta->>'data_store_type' = ?", "ALLOWANCE_COMPUTATION") }
  scope :kbente_summary, -> { where("meta->>'data_store_type' = ?", "KBENTE_SUMMARY") }
  scope :kkalinga_summary, -> { where("meta->>'data_store_type' = ?", "KKALINGA_SUMMARY") }
  scope :kok_summary, -> { where("meta->>'data_store_type' = ?", "KOK_SUMMARY") }

  # For attaching json dumps
  has_one_attached :data_json_dump

  before_validation :load_defaults

  def data_json_dump_url
    return rails_blob_path(self.data_json_dump, only_path: true)
  end

  def load_defaults
    if self.new_record? && self.status.blank?
      self.status = "processing"
    end

    if self.meta.present? and self.meta["as_of"].present?
      self.as_of = self.meta["as_of"]
    end

    if self.meta.present? and self.meta["start_date"].present? and self.meta["end_date"].present?
      self.start_date = self.meta["start_date"]
      self.end_date   = self.meta["end_date"]
    end
  end

  def year
    if self.as_of.present?
      return self.as_of.to_date.year
    else
      return "N/A"
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
