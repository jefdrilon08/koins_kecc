class KalingaClaim < ApplicationRecord

	GENDER = ["Male", "Female"]
	PURPOSE = ["Payment for K-Kalinga Accidental Death", "Payment for K-Kalinga Fire Assistance"]
	CIVIL_STATUS = ["Single", "Married", "Widowed"]
	REASON_OF_CLAIMS = ["Accidental Death", "Fire"]
	
	validates :date_reported, presence: true
	validates :date_emailed, presence: true
	validates :date_approved, presence: true
	validates :date_requested, presence: true
	validates :purpose, presence: true
	validates :amount, presence: true
	validates :poc_number, presence: true
	validates :issueddate, presence: true
	validates :effective_date, presence: true
	validates :expiration_date, presence: true
	validates :name_of_insured, presence: true
	validates :date_of_birth, presence: true
	validates :gender, presence: true
	validates :civil_status, presence: true
	validates :insured_address, presence: true
	validates :name_of_beneficiary, presence: true
	validates :relationship_to_member, presence: true
	validates :date_of_death_or_incident, presence: true
	validates :relationship_to_member, presence: true
	validates :reason_of_death, presence: true
	# validates :name_of_member, presence: true
	validates :member_branch, presence: true
	# validates :member_identification_number, presence: true

	def branch_name
		Branch.where(id: self.member_branch).first
	end
end
