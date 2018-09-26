class AccountingCode < ApplicationRecord
  CATEGORIES  = [
    "ASSETS",
    "LIABILITIES",
    "EQUITIES",
    "EXPENSES",
    "INCOME"
  ]

  validates :name, presence: true, uniqueness: true
  validates :code, presence: true, uniqueness: true
  validates :category, presence: true, inclusion: { in: CATEGORIES }

  scope :assets, -> { where(category: "ASSETS").order("code ASC") }
  scope :equities, -> { where(category: "EQUITIES").order("code ASC") }
  scope :expenses, -> { where(category: "EXPENSES").order("code ASC") }
  scope :income, -> { where(category: "INCOME").order("code ASC") }
  scope :liabilities, -> { where(category: "LIABILITIES").order("code ASC") }

  before_validation :load_defaults

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
