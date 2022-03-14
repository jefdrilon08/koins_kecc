class CommissionCollection < ApplicationRecord
  STATUSES  = [
    "processing", 
    "pending", 
    "approved",
    "error"
    ]

  validates :date_prepared, presence: true

  scope :pending, -> { where(status: "pending") }
  scope :approved, -> { where(status: "approved") }
  scope :processing, -> { where(status: "processing") }
  scope :error, -> { where(status: "error") }

  def book
    temp_data = self.data.with_indifferent_access

    temp_data[:accounting_entry][:book]
  end

  def particular
    temp_data = self.data.with_indifferent_access

    temp_data[:accounting_entry][:particular]
  end

  def or_number
    temp_data = self.data.with_indifferent_access

    temp_data[:accounting_entry][:data][:or_number]
  end

  def check_number
    temp_data = self.data.with_indifferent_access

    temp_data[:accounting_entry][:data][:check_number]
  end

  def check_voucher_number
    temp_data = self.data.with_indifferent_access

    temp_data[:accounting_entry][:data][:check_voucher_number]
  end

  def payee
    temp_data = self.data.with_indifferent_access

    temp_data[:accounting_entry][:data][:payee]
  end

  def template
    temp_data = self.data.with_indifferent_access 

    if temp_data[:template].present?
      temp_data[:template]
    else
      "default"
    end
  end

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
end
