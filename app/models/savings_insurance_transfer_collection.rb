class SavingsInsuranceTransferCollection < ApplicationRecord
  STATUSES  = [
    "pending",
    "approved",
    "processing",
    "error"
  ]

  belongs_to :center
  belongs_to :branch

  validates :collection_date, presence: true

  before_validation :load_defaults

  scope :pending, -> { where(status: "pending").order("collection_date ASC") }
  scope :approved, -> { where(status: "approved").order("collection_date ASC") }

  def to_s
    if !Settings.activate_microinsurance
      "#{self.branch.name} #{self.collection_date.strftime("%B %d, %Y")}: #{self.data['savings_subtype']} to #{self.data['insurance_subtype']}"
    else
      "#{self.branch.name} #{self.collection_date.strftime("%B %d, %Y")}: #{self.data['payment_subtype']} to #{self.data['insurance_subtype']}"
    end
  end

  def load_defaults
    if self.status.blank?
      self.status = "pending"
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

  def savings_insurance_transfers
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

  def prepared_by
    temp  = self.data.with_indifferent_access

    if temp[:prepared_by].present?
      return temp[:prepared_by]
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

  def error?
    self.status == "error"
  end

  def member_ids
    self.data.with_indifferent_access[:records].map{ |o| o[:member][:id] }
  end

  def clip
    self.data.with_indifferent_access[:insurance_subtype] == "Credit Life Insurance Plan"
  end

  def kbente
    self.data.with_indifferent_access[:insurance_subtype] == "K-BENTE"
  end

  def kkalinga
    self.data.with_indifferent_access[:insurance_subtype] == "K-KALINGA"
  end
  
  def accounting_entry
    self.data.with_indifferent_access[:accounting_entry]
  end  
  
end
