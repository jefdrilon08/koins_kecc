class Beneficiary < ApplicationRecord
  belongs_to :member

  def full_name
    "#{last_name}, #{first_name} #{middle_name}"
  end

  def full_name_upcase
    "#{first_name.try(:upcase)} #{middle_name.try(:upcase)} #{last_name.try(:upcase)}"
  end
end
