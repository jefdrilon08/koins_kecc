class WithdrawalCollection < ApplicationRecord
  STATUSES  = [
    "pending",
    "approved",
    "processing"
  ]

  belongs_to :center, optional: true
  belongs_to :branch

  validates :status, presence: true, inclusion: { in: STATUSES }

  before_validation :load_defaults

  scope :pending, -> { where(status: "pending").order("collection_date ASC") }
  scope :approved, -> { where(status: "approved").order("collection_date ASC") }
  scope :processing, -> { where(status: "processing").order("collection_date ASC") }
  def not_pending?
    self.status != "pending"
  end

  def cash_management_template
    temp_date = self.data.with_indifferent_access 

    if temp_data[:cash_management_template].present?
      temp_data[:cash_management_template]
    else
      "default"
    end
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

  def withdrawals
    records = []
    self.data.with_indifferent_access[:records].each do |o|
      o[:records].each do |oo|
        if oo[:amount].try(:to_f) > 0
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
  def processing?
    self.status == "processing"
  end

end
