class AccountingEntry < ApplicationRecord
  BOOKS = [
    "CRB",
    "CDB",
    "JVB",
    "MISC"
  ]

  STATUSES  = [
    "pending",
    "approved"
  ]

  belongs_to :branch

  has_many :journal_entries

  validates :particular, presence: true
  validates :reference_number, presence: true, uniqueness: { scope: :branch_id }
  validates :date_prepared, presence: true
  validates :status, presence: true

  scope :approved, -> { where(status: "approved").order("date_prepared, date_posted DESC") }
  scope :pending, -> { where(status: "pending").order("date_prepared DESC") }

  scope :jvb, -> { includes(:journal_entries).where(book: "JVB").order("date_prepared DESC") }
  scope :crb, -> { includes(:journal_entries).where(book: "CRB").order("date_prepared DESC") }
  scope :cdb, -> { includes(:journal_entries).where(book: "CDB").order("date_prepared DESC") }
  scope :misc, -> { includes(:journal_entries).where(book: "MISC").order("date_prepared DESC") }

  def approved?
    self.status == "approved"
  end

  def pending?
    self.status == "pending"
  end
end
