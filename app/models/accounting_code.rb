class AccountingCode < ApplicationRecord
  CATEGORIES  = [
    "ASSETS",       # DR
    "LIABILITIES",  # CR
    "EQUITIES",     # CR
    "EXPENSES",     # DR
    "INCOME"        # CR 
  ]

  validates :name, presence: true, uniqueness: true
  validates :code, presence: true, uniqueness: true
  validates :category, presence: true, inclusion: { in: CATEGORIES }

  scope :assets, -> { where(category: "ASSETS").order("code ASC") }
  scope :equities, -> { where(category: "EQUITIES").order("code ASC") }
  scope :expenses, -> { where(category: "EXPENSES").order("code ASC") }
  scope :income, -> { where(category: "INCOME").order("code ASC") }
  scope :liabilities, -> { where(category: "LIABILITIES").order("code ASC") }

  scope :income_and_expenses, -> { where(category: ["INCOME", "EXPENSES"]).order("code ASC") }
  scope :assets_and_liabilities_and_equities, -> { where(category: ["ASSETS", "EQUITIES", "LIABILITIES"]).order("code ASC") }

  has_many :journal_entries

  before_validation :load_defaults

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
    if name.present?
      self.name = self.name.upcase
    end

    if code.present?
      self.code = self.code.upcase
    end
  end

  def to_s
    name
  end
end
