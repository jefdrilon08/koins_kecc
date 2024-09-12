class LoanApplication < ApplicationRecord
  STATUSES = [
    "pending",
    "for_review",
    "for_approve",
    "approved",
    "reject"
  ]

  belongs_to :loan_product
  belongs_to :member
  belongs_to :co_maker_member, class_name: "Member", foreign_key: "co_maker_member_id"

  validates :amount, presence: true, numericality: true
  validates :term, presence: true
  validates :num_installments, presence: true
  validates :status, presence: true
  validates :reference_number, presence: true, uniqueness: true
  validates :date_applied, presence: true

  before_validation :load_defaults

  scope :pending, -> { where(status: "pending") }
  scope :processing, -> { where(status: "processing") }
  scope :pending_or_processing, -> { where(status: ["pending", "processing"]) }
  scope :reject_or_rejected, -> { where(status: ["reject", "rejected"]) }
  def to_h
    {
      id: self.id,
      reference_number: self.reference_number,
      amount: self.amount,
      status: self.status,
      date_applied: self.date_applied.try(:strftime, "%m %d, %Y"),
      loan_product: self.loan_product.to_h
    }
  end
  def pending?
    self.status == "pending"
  end
  def for_review?
    self.status == "for_review"
  end

  def for_approve?
    self.status == "for_approve"
  end
  def approved?
    self.status == "approved"
  end
  def reject?
    self.status == "reject"
  end

  def load_defaults
    if self.status.blank?
      self.status = 'pending'
    end
  end
end
