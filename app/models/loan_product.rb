class LoanProduct < ApplicationRecord
  validates :name, presence: true, uniqueness: true
  validates :max_loan_amount, presence: true, numericality: true
  validates :min_loan_amount, presence: true, numericality: true
  validates :monthly_interest_rate, presence: true, numericality: true
  validates :non_teaching_monthly_interest_rate, presence: true, numericality: true


  belongs_to :loan_product_category, optional: true
  has_many :loan_product_types, dependent: :delete_all
  has_many :loan_product_taggings, dependent: :delete_all

  scope :entry_point, -> { where(is_entry_point: true, is_active: true) }
  scope :non_entry_point, -> { where.not(is_entry_point: true, is_active: true) }

  def to_h
    {
      id: self.id,
      name: self.name,
      max_loan_amount: self.max_loan_amount.round(2),
      min_loan_amount: self.min_loan_amount.round(2), 
      denomination: self.denomination.round(2),
      insured: self.insured,
      is_entry_point: self.is_entry_point,
      is_active: self.is_active,
      monthly_interest_rate: self.monthly_interest_rate,
      non_teaching_monthly_interest_rate: self.non_teaching_monthly_interest_rate,
      priority: self.priority,
      data: self.data
    }
  end

  def to_s
    name
  end

  def maintaining_balance
    if data
      temp  = self.data.with_indifferent_access

      if temp[:maintaining_balance].present?
        temp[:maintaining_balance].to_f.round(2)
      else
        0.00
      end
    else
      0.00
    end
  end

  def prerequisite
    if data
      temp  = self.data.with_indifferent_access

      if temp[:prerequisite_id].present?
        LoanProduct.where(id: temp[:prerequisite_id]).first
      else
        false
      end
    else
      false
    end
  end
end
