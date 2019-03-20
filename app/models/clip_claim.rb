class ClipClaim < ApplicationRecord
	GENDER = ["Male", "Female"]
	CREDITORS_NAME = ["KCOOP", "JVOMFI", "CAPS-R"]
  	CAUSE_OF_DEATH = ["Cardiovascular", "Respiratory", "Hematological", "Gastro Intestinal", "Gynecological", "Neurological", "Suicide", "Others"]
  	TYPES_OF_LOAN = ["K_NEGOSYO", "K-KABUHAYAN"]

	belongs_to :branch
	belongs_to :center
	belongs_to :member

	validates :member, presence: true

	def age
    if self.date_of_birth.nil?
      "Please set date of birth"
    else
      begin
        now = self.date_of_death
        now.year - self.date_of_birth.year - (self.date_of_birth.to_date.change(:year => now.year) > now ? 1 : 0)
      rescue Exception
        "Invalid date of birth: #{self.date_of_birth}"
      end
    end
	end
end
