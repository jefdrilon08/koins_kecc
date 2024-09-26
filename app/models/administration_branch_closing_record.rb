class AdministrationBranchClosingRecord < ApplicationRecord
  RECORD_TYPES = [
    "TRIAL_BALANCE",
    "REPAYMENT_RATES",
    "GENERAL_LEDGER",
    "BALANCE_SHEET",
    "INCOME_STATEMENT",
    "SOA_FUNDS",
    "SOA_EXPENSES",
    "SOA_LOANS",
    "MANUAL_AGING",
    "PERSONAL_FUNDS",
    "MEMBER_COUNTS",
    "MONTHLY_NEW_AND_RESIGNED"
  ]

  belongs_to :data_store, optional: true
  belongs_to :branch

  validates :record_type, presence: true, inclusion: { in:  RECORD_TYPES }
  validates :closing_date, presence: true
end
