class AccountTransactionCollection < ApplicationRecord
  belongs_to :branch
  belongs_to :center

  validates :total_amount, presence: true, numericality: true
end
