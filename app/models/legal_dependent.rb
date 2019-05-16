class LegalDependent < ApplicationRecord
  belongs_to :member

  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :date_of_birth, presence: true

  def full_name
    "#{last_name}, #{first_name} #{middle_name}"
  end
  def age
    if self.date_of_birth.nil?
      "Please set date of birth"
    else
      begin
        ((Time.zone.now - date_of_birth.to_time) / 1.year.seconds).floor
      rescue Exception
        "ERR IN AGE"
      end
    end
  end
end
