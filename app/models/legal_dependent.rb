class LegalDependent < ApplicationRecord
  belongs_to :member

  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :date_of_birth, presence: true
end
