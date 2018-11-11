class Loan < ApplicationRecord
  STATUSES  = [
    "pending",
    "active",
    "paid"
  ]

  belongs_to :center
  belongs_to :branch
  belongs_to :member
  belongs_to :loan_product
  belongs_to :project_type, optional: true

  scope :pending, -> { where(status: "pending") }
  scope :active, -> { where(status: "active") }
  scope :paid, -> { where(status: "paid") }
  scope :active_or_paid, -> { where(status: ["active", "paid"]) }

  has_many :amortization_schedule_entries

  def total_balance
    self.principal_balance + self.interest_balance
  end

  def total_dues
    self.principal + self.interest
  end

  def total_paid
    self.principal_paid + self.interest_paid
  end

  def active_or_paid?
    ["active", "paid"].include?(self.status)
  end

  def pending?
    self.status == "pending"
  end

  def paid?
    self.status == "paid"
  end

  def active?
    self.status == "active"
  end
end
