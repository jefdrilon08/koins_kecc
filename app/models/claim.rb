class Claim < ApplicationRecord
	INSURANCE_POLICY_TYPES = ["Basic Life", "Accidental Death", "TPD", "MVAH"]
	INSURED_CLASSIFICATION = ["Member", "Legal Dependent (Spouse)", "Legal Dependent (Child)", "Legal Dependent (Parent)"]
	CATEGORY_OF_CAUSE_OF_DEATH_TPD_ACCIDENT = ["Cardiovascular", "Respiratory", "Hematological", "Gastro Intestinal", "Gynecological", "Neurological", "Suicide", "Motor Vehicular Accident", "Others"]
	GENDER = ["Male", "Female"]

	belongs_to :branch
	belongs_to :center
	belongs_to :member

  validates :date_reported, presence: true
  validates :member, presence: true
	def age
    	if self.date_of_birth.nil?
      		"Please set date of birth"
    	else
      		begin
        		now = self.date_of_death_tpd_accident
        		now.year - self.date_of_birth.year - (self.date_of_birth.to_date.change(:year => now.year) > now ? 1 : 0)
      		rescue Exception
        		"Invalid date of birth: #{self.date_of_birth}"
      	end
    end
  end
end
