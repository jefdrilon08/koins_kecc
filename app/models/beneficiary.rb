class Beneficiary < ApplicationRecord
  belongs_to :member

  def full_name
    "#{last_name}, #{first_name} #{middle_name}"
  end
end
