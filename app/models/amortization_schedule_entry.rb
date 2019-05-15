class AmortizationScheduleEntry < ApplicationRecord
  belongs_to :loan

  scope :unpaid, -> { where(is_paid: nil).order("due_date ASC") }
  scope :paid, -> { where(is_paid: true).order("due_date ASC") }

  before_validation :load_defaults

  def load_defaults
    if self.principal_balance == 0.00 && self.interest_balance == 0.00
      self.is_paid = true
    end
  end

  def total_paid
    principal_paid + interest_paid
  end

  def total_balance
    principal_balance + interest_balance
  end
end
