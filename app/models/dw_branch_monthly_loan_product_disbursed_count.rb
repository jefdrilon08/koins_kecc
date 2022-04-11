class DwBranchMonthlyLoanProductDisbursedCount < ApplicationRecord
  belongs_to :branch
  belongs_to :area
  belongs_to :cluster
  belongs_to :loan_product
  belongs_to :loan_product_category
end
