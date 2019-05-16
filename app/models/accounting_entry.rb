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
  belongs_to :accounting_fund, optional: true

  has_many :journal_entries, dependent: :destroy

  validates :particular, presence: true
  validates :reference_number, presence: true, uniqueness: { scope: [:branch_id, :book] }, if: :approved?
  validates :date_prepared, presence: true
  validates :status, presence: true

  scope :approved, -> { where(status: "approved").order("reference_number ASC") }
  scope :pending, -> { where(status: "pending").order("date_prepared DESC") }

  scope :jvb, -> { includes(:journal_entries).where(book: "JVB").order("date_prepared DESC") }
  scope :crb, -> { includes(:journal_entries).where(book: "CRB").order("date_prepared DESC") }
  scope :cdb, -> { includes(:journal_entries).where(book: "CDB").order("date_prepared DESC") }
  scope :misc, -> { includes(:journal_entries).where(book: "MISC").order("date_prepared DESC") }

  before_validation :load_defaults
  
  
  def load_defaults
    if self.new_record?
      self.status = "pending"
    end
  end

  def approved?
    self.status == "approved"
  end

  def pending?
    self.status == "pending"
  end

  def crb?
    self.book == "CRB"
  end

  def jvb?
    self.book == "JVB"
  end

  def cdb?
    self.book == "CDB"
  end

  def misc?
    self.book == "MISC"
  end
end
