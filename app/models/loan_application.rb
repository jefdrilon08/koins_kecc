class LoanApplication < ApplicationRecord
  belongs_to :loan_product
  belongs_to :loan_product_type
  belongs_to :member
end
