class Billing < ApplicationRecord
  STATUSES  = [
    "pending",
    "save",
    "checked",
    "approved",
    "processing",
    "error"
  ]
  
  BILLING_TYPES  = [
    "regular",
    "for-involutary"
  ]

  belongs_to :center
  belongs_to :branch

  validates :collection_date, presence: true

  before_validation :load_defaults

  scope :save, -> { where(status: "save").order("collection_date ASC") }
  scope :pending, -> { where(status: "pending").order("collection_date ASC") }
  scope :approved, -> { where(status: "approved").order("collection_date ASC") }
  scope :processing, -> { where(status: "processing").order("collection_date ASC") }

  def load_defaults
    if self.status.blank?
      self.status = "pending"
    end

    if self.data.present?
      if self.data["or_number"].present?
        self.or_number = self.data["or_number"]
      end

      if self.data["ar_number"].present?
        self.ar_number = self.data["ar_number"]
      end

      if self.data["total_expected_collections"].present?
        self.total_expected_collections = self.data["total_expected_collections"].to_f.round(2)
      end

      if self.data["total_collected"].present?
        self.total_collected = self.data["total_collected"].to_f.round(2)
      end
    end
  end

  def checked?
    temp  = self.data.with_indifferent_access

    temp[:is_checked].present? && temp[:is_checked] == true
  end

  def prepared_by
    temp  = self.data.with_indifferent_access

    if temp[:prepared_by].present?
      return temp[:prepared_by]
    else
      return "N/A"
    end
  end

  def checked_by
    temp  = self.data.with_indifferent_access

    if temp[:is_checked].present? && temp[:checker].present?
      return "#{temp[:checker][:first_name]} #{temp[:checker][:last_name]}"
    else
      return "N/A"
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
  def save?
    self.status == "save"
  end
  
  def checked?
    self.status == "checked"
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
  
  def equity
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

  def member_ids
    self.data.with_indifferent_access[:records].map{ |o| o[:member][:id] }
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

  def book
    self.data.with_indifferent_access[:book]
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
