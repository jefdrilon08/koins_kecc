class LoanProductCategory < ApplicationRecord
  validates :name, presence: true, uniqueness: true
  validates :code, presence: true, uniqueness: true

  has_many :loan_products, dependent: :nullify

  def to_s
    name
  end
end
