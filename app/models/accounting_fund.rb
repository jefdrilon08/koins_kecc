class AccountingFund < ApplicationRecord
  validates :name, presence: true, uniqueness: true

  has_many :accounting_entries

  def prefix
    self.name.split(" ").map{ |o| o.split('').first.try(:upcase) }.join
  end

  def to_s
    name
  end
end
