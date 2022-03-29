class DwBranchLoanProductActiveLoanCount < ApplicationRecord
  belongs_to :branch
  belongs_to :cluster
  belongs_to :area
  belongs_to :loan_product
  belongs_to :loan_product_category

  validates :as_of, presence: true
  validates :total, presence: true
  validates :month, presence: true
  validates :year, presence: true
end
