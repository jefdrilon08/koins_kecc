class AccountingCode < ApplicationRecord
  CATEGORIES  = [
    "ASSETS",       # DR
    "LIABILITIES",  # CR
    "EQUITIES",     # CR
    "EXPENSES",     # DR
    "INCOME",       # CR
    "FUND BALANCE",  # DR
    "CASH ON HAND",
    "CASH IN BANKS",
    "SHORT TERM INVESTMENTS",
    "LONG TERM INVESTMENT",
    "COOPERATIVES",
    "CASH ADVANCE TO OFFICERS AND EMPLOYEES",
    "LOANS RECEIVABLES",
    "CASH ADVANCE TO MEMBERS",
    "CASH ADVANCE TO OFFICERS AND EMPL.",
    "EQUIPMENTS",
    "WITHHOLDING TAX PAYABLE",
    "SSS, EC PAYABLE",
    "PAG-IBIG PAYABLE",
    "PHIL. HEALTH PAYABLE",
    "SSS LOAN PAYABLE",
    "PAG-IBIG LOAN PAYABLE",
    "SAVINGS DEPOSIT",
    "MUTUAL BENEFIT FUND",
    "DIVIDEND AND PATRONAGE REFUND PAYABLE",
    "PAID-UP SHARE CAPITAL COMMON",
    "STATUTORY FUND",
    "INTEREST INCOME FROM LOANS",
    "FILING FEES",
    "SERVICE FEES",
    "MEMBERSHIP FEES",
    "FINES",
    "INTEREST INCOME FROM BANK DEPOSITS",
    "MISCELLANEOUS INCOME"
  ]

  validates :name, presence: true, uniqueness: true
  validates :code, presence: true, uniqueness: true
  validates :category, presence: true, inclusion: { in: CATEGORIES }

  scope :assets, -> { where(category: "ASSETS").order("code ASC") }
  scope :equities, -> { where(category: "EQUITIES").order("code ASC") }
  scope :expenses, -> { where(category: "EXPENSES").order("code ASC") }
  scope :income, -> { where(category: "INCOME").order("code ASC") }
  scope :liabilities, -> { where(category: "LIABILITIES").order("code ASC") }
  scope :fund_balance, -> { where(category: "FUND BALANCE").order("code ASC") }

  scope :income_and_expenses, -> { where(category: ["INCOME", "EXPENSES"]).order("code ASC") }
  scope :assets_and_liabilities_and_equities, -> { where(category: ["ASSETS", "EQUITIES", "LIABILITIES"]).order("code ASC") }

  scope :debits, -> { where(category: ["ASSETS", "EXPENSES", "FUND BALANCE"]).order("code ASC") }
  scope :credits, -> { where(category: ["LIABILITIES", "EQUITIES", "INCOME"]).order("code ASC") }

  has_many :journal_entries

  before_validation :load_defaults

  def to_h
    {
      id: id,
      name: name,
      code: code,
      category: category,
      data: data
    }
  end

  def to_version_2_hash
    {
      id: id,
      name: name,
      code: code,
      category: category,
      data: data
    }
  end

  def debit_entry?
    ["ASSETS", "EXPENSES"].include?(self.category)
  end

  def credit_entry?
    !self.debit_entry?
  end

  def load_defaults
  end

  def to_s
    name
  end
end
