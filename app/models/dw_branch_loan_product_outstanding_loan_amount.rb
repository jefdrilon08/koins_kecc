class DwBranchLoanProductOutstandingLoanAmount < ApplicationRecord
  belongs_to :branch
  belongs_to :cluster
  belongs_to :area
  belongs_to :loan_product_category
end
