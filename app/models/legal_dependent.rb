class LegalDependent < ApplicationRecord
  belongs_to :member

  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :date_of_birth, presence: true

  def full_name
    "#{last_name}, #{first_name} #{middle_name}"
  end
end
