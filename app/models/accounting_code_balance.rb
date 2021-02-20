class AccountingCodeBalance < ApplicationRecord
  STATUSES = [
    "processing",
    "done"
  ]

  belongs_to :accounting_code
  belongs_to :accounting_fund, optional: true
  belongs_to :branch

  validates :category, presence: true, inclusion: { in: AccountingCode::CATEGORIES }
  validates :start_date, presence: true
  validates :end_date, presence: true
  validates :total_beginning_debit, presence: true, numericality: true
  validates :total_beginning_credit, presence: true, numericality: true
  validates :total_current_debit, presence: true, numericality: true
  validates :total_current_credit, presence: true, numericality: true
  validates :total_ending_debit, presence: true, numericality: true
  validates :total_ending_credit, presence: true, numericality: true

  scope :assets, -> { joins(:accounting_code).where("accounting_code_balances.category = ?", "ASSETS").order("code ASC") }
  scope :equities, -> { joins(:accounting_code).where("accounting_code_balances.category = ?", "EQUITIES").order("code ASC") }
  scope :expenses, -> { joins(:accounting_code).where("accounting_code_balances.category = ?", "EXPENSES").order("code ASC") }
  scope :income, -> { joins(:accounting_code).where("accounting_code_balances.category = ?", "INCOME").order("code ASC") }
  scope :liabilities, -> { joins(:accounting_code).where("accounting_code_balances.category = ?", "LIABILITIES").order("code ASC") }
  scope :fund_balance, -> { joins(:accounting_code).where("accounting_code_balances.category = ?", "FUND BALANCE").order("code ASC") }

  scope :processing, -> { where(status: "processing") }
  scope :done, -> { where(status: "done") }

  before_validation :load_defaults

  def load_defaults
    self.status                 = "processing" if self.status.blank?
    self.total_beginning_debit  = 0.00 if self.total_beginning_debit.blank?
    self.total_beginning_credit = 0.00 if self.total_beginning_credit.blank?
    self.total_current_debit    = 0.00 if self.total_current_debit.blank?
    self.total_current_credit   = 0.00 if self.total_current_credit.blank?
    self.total_ending_debit     = 0.00 if self.total_ending_debit.blank?
    self.total_ending_credit    = 0.00 if self.total_ending_credit.blank?
  end

  def processing?
    self.status == "processing"
  end

  def done?
    self.status == "done"
  end
end
