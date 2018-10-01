class Loan < ApplicationRecord
  belongs_to :center
  belongs_to :branch
  belongs_to :member
  belongs_to :loan_product
  belongs_to :project_type
end
