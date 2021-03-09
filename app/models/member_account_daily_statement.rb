class MemberAccountDailyStatement < ApplicationRecord
  belongs_to :member
  belongs_to :member_account
  belongs_to :branch

  validates :debit_amount, presence: true, numericality: true
  validates :credit_amount, presence: true, numericality: true
  validates :transacted_at, presence: true
end
