class MonthlyClosingCollection < ApplicationRecord
  STATUSES  = [
    "processing", 
    "pending", 
    "approved",
    "error"
  ]

  belongs_to :branch

  validates :closing_date, presence: true

  scope :pending, -> { where(status: "pending") }
  scope :approved, -> { where(status: "approved") }
  scope :processing, -> { where(status: "processing") }
  scope :error, -> { where(status: "error") }

  def processing?
    self.status == "processing"
  end

  def pending?
    self.status == "pending"
  end

  def approved?
    self.status == "approved"
  end

  def error?
    self.status == "error"
  end

  def to_s
    closing_date
  end

  def member_account_ids
    self.data.with_indifferent_access[:records].map{ |r|
      r[:member_account][:id]
    }
  end
end
