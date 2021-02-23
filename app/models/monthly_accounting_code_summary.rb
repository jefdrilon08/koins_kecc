class MonthlyAccountingCodeSummary < ApplicationRecord
  belongs_to :branch
  belongs_to :accounting_code

  validates :month, presence: true, numericality: true, inclusion: [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12]
  validates :year, presence: true, numericality: true
  validates :category, presence: true
  validates :dr_amount, presence: true, numericality: true
  validates :cr_amount, presence: true, numericality: true

  before_validation :load_defaults

  def load_defaults
    if self.accounting_code.present?
      self.category = self.accounting_code.category
      self.name     = self.accounting_code.name
    end
  end
end
