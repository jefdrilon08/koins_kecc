class LoanRepaymentRate < ApplicationRecord
  belongs_to :loan
  belongs_to :branch
  belongs_to :center

  validates :as_of, presence: true
end
