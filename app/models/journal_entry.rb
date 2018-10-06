class JournalEntry < ApplicationRecord
  POST_TYPES  = [
    "DR",
    "CR"
  ]

  belongs_to :accounting_code
  belongs_to :accounting_entry

  validates :post_type, presence: true, inclusion: { in: POST_TYPES }
  validates :amount, presence: true, numericality: true

  scope :debit, -> { joins(:accounting_code).where("post_type = 'DR' AND amount > 0").order("accounting_codes.code ASC") }
  scope :credit, -> { joins(:accounting_code).where("post_type = 'CR' AND amount > 0").order("accounting_codes.code ASC") }
end
