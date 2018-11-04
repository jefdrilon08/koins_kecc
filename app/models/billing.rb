class Billing < ApplicationRecord
  STATUSES  = [
    "pending",
    "approved"
  ]

  belongs_to :center
  belongs_to :branch

  validates :collection_date, presence: true

  before_validation :load_defaults

  scope :pending, -> { where(status: "pending").order("collection_date ASC") }
  scope :approved, -> { where(status: "approved").order("collection_date ASC") }

  def load_defaults
    if self.status.blank?
      self.status = "pending"
    end
  end

  def total_expected_collections
    self.data["total_expected_collections"]
  end

  def total_collected
    self.data["total_collected"]
  end

  def pending?
    self.status == "pending"
  end

  def approved?
    self.status == "approved"
  end
end
