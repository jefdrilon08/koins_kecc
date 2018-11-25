class MembershipPaymentCollection < ApplicationRecord
  STATUSES  = [
    "pending",
    "approved"
  ]

  belongs_to :center
  belongs_to :branch

  validates :status, presence: true, inclusion: { in: STATUSES }

  before_validation :load_defaults

  scope :pending, -> { where(status: "pending").order("collection_date ASC") }
  scope :approved, -> { where(status: "approved").order("collection_date ASC") }

  def not_pending?
    self.status != "pending"
  end

  def member_ids
    records = []
    self.data.with_indifferent_access[:records].each do |o|
      o[:records].each do |oo|
        if oo[:member_id].present?
          records << oo[:member_id]
        end
      end
    end

    records.uniq
  end

  def id_payments
    records = []
    self.data.with_indifferent_access[:records].each do |o|
      o[:records].each do |oo|
        if oo[:record_type] == "ID" and oo[:amount].try(:to_f) > 0
          records << oo
        end
      end
    end

    records
  end

  def membership_payments
    records = []
    self.data.with_indifferent_access[:records].each do |o|
      o[:records].each do |oo|
        if oo[:record_type] == "MEMBERSHIP_PAYMENT" and oo[:amount].try(:to_f) > 0
          records << oo
        end
      end
    end

    records
  end

  def equities
    records = []
    self.data.with_indifferent_access[:records].each do |o|
      o[:records].each do |oo|
        if oo[:record_type] == "EQUITY" and oo[:amount].try(:to_f) > 0
          records << oo
        end
      end
    end

    records
  end

  def total_collected
    self.data["total_collected"]
  end

  def accounting_entry
    self.data.with_indifferent_access[:accounting_entry]
  end

  def load_defaults
    if self.status.blank?
      self.status = "pending"
    end
  end

  def pending?
    self.status == "pending"
  end

  def approved?
    self.status == "approved"
  end
end
