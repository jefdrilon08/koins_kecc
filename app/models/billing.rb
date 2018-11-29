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

  def loan_payments
    records = []
    self.data.with_indifferent_access[:records].each do |o|
      o[:records].each do |oo|
        if oo[:record_type] == "LOAN_PAYMENT" and oo[:amount].try(:to_f) > 0
          records << oo
        end
      end
    end

    records
  end

  def deposits
    records = []
    self.data.with_indifferent_access[:records].each do |o|
      o[:records].each do |oo|
        if oo[:record_type] == "SAVINGS" and oo[:amount].try(:to_f) > 0
          records << oo
        end
      end
    end

    records
  end

  def reference_number
    self.data.with_indifferent_access[:accounting_entry][:reference_number]
  end

  def particular
    self.data.with_indifferent_access[:accounting_entry][:particular]
  end

  def insurance
    records = []
    self.data.with_indifferent_access[:records].each do |o|
      o[:records].each do |oo|
        if oo[:record_type] == "INSURANCE" and oo[:amount].try(:to_f) > 0
          records << oo
        end
      end
    end

    records
  end

  def withdraw_payments
    records = []
    self.data.with_indifferent_access[:records].each do |o|
      o[:records].each do |oo|
        if oo[:record_type] == "WP" and oo[:amount].try(:to_f) > 0
          oo[:member] = {
            full_name: o[:member][:full_name]
          }

          records << oo
        end
      end
    end

    records
  end

  def or_number
    self.data.with_indifferent_access[:or_number]
  end

  def book
    self.data.with_indifferent_access[:book]
  end

  def date_approved
    if self.approved?
      AccountingEntry.where(
        reference_number: self.reference_number,
        book: self.book
      ).first.date_posted.strftime("%B %d, %Y")
    end
  end

  def book
    self.data.with_indifferent_access[:accounting_entry][:book]
  end

  def approved_by
    self.data.with_indifferent_access[:approved_by]
  end

  def accounting_entry
    self.data.with_indifferent_access[:accounting_entry]
  end
end
