class DwBranchMonthlyLoanAmountCollection < ApplicationRecord
  belongs_to :branch
  belongs_to :area
  belongs_to :cluster
end
