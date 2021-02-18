class JournalEntry < ApplicationRecord
  POST_TYPES  = [
    "DR",
    "CR"
  ]

  belongs_to :accounting_code
  belongs_to :accounting_entry

  belongs_to :branch, optional: true
  belongs_to :accounting_fund, optional: true

  validates :post_type, presence: true, inclusion: { in: POST_TYPES }
  validates :amount, presence: true, numericality: true

  scope :debit, -> { joins(:accounting_code).where("post_type = 'DR' AND amount <> 0").order("accounting_codes.code ASC") }
  scope :credit, -> { joins(:accounting_code).where("post_type = 'CR' AND amount <> 0").order("accounting_codes.code ASC") }
  scope :approved, -> { where(status: "approved") }
  scope :pending, -> { where(status: "pending") }

  before_validation :load_defaults

  def load_defaults
    if self.accounting_entry.present?
      if self.accounting_entry.book.present?
        self.book = self.accounting_entry.book
      end

      if self.accounting_entry.branch_id.present?
        self.branch_id = self.accounting_entry.branch_id
      end

      if self.accounting_entry.accounting_fund_id.present?
        self.accounting_fund_id = self.accounting_entry.accounting_fund_id
      end

      if self.accounting_entry.status.present?
        self.status = self.accounting_entry.status
      end

      if self.accounting_entry.date_posted.present?
        self.date_posted = self.accounting_entry.date_posted
      end

      if self.accounting_entry.date_prepared.present?
        self.date_prepared = self.accounting_entry.date_prepared
      end

      if self.accounting_entry.data["is_closing_record"].present?
        if self.data.blank?
          self.data = {
            "is_closing_record": true
          }
        else
          self.data["is_closing_record"] = true
        end
      end
    end
  end

  def debit?
    self.post_type == "DR"
  end

  def credit?
    self.post_type == "CR"
  end
end
