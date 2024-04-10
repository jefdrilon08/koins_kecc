class InsuranceLoanBundleEnrollment < ApplicationRecord
  STATUSES  = [
    "pending",
    "approved",
    "for_checking",
    "for-approval",
    "processing",
    "for-renewal",
    "declined",
    "error"
  ]

  belongs_to :center
  belongs_to :branch
  
  validates :collection_date, presence: true

  before_validation :load_defaults

  scope :pending, -> { where(status: "pending").order("collection_date ASC") }
  scope :approved, -> { where(status: "approved").order("collection_date ASC") }
  scope :for_checking, -> { where(status: "for_checking").order("collection_date ASC") }
  scope :approved, -> { where(status: "approved").order("collection_date ASC") }
  scope :declined, -> { where(status: "declined").order("collection_date ASC") }

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

  def insurance_loan_bundles
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

  def checked?
    self.status == "for-approval"
  end

  def declined?
    self.status == "declined"
  end

  def approved?
    self.status == "approved"
  end

  def for_renewal?
    self.status == "for-renewal"
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

  def member_name
    self.data.with_indifferent_access[:records].map{ |o| o[:member][:full_name] }
  end
 
  def member_dependent_name
    self.data.with_indifferent_access[:records].map{ |o| o[:kok_data][:full_name_dependent] }
  end

  def is_dependent?
    self.data.with_indifferent_access[:records][0][:kok_data][:client_type] == "DEPENDENT"
  end

  def is_principal?
    self.data.with_indifferent_access[:records][0][:kok_data][:client_type] == "PRINCIPAL/MEMBER"
  end

  def records_count
    self.data.with_indifferent_access[:records].count
  end

  def records_last
    self.data.with_indifferent_access[:records].last
  end

end
