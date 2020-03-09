class KalingaClaim < ApplicationRecord
	belongs_to :branch
	belongs_to :center
	belongs_to :member

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

	def kalinga_hash

	    {
	      id: self.id,
	      center_id: self.center_id,
      	  branch_id: self.branch_id,
          member_id: self.member_id,
	      claim_type: "K-KALINGA",
	      prepared_by: self.prepared_by,
	      date_prepared: self.created_at,
	      created_at: self.created_at,
	      updated_at: self.updated_at,
	      status: "pending",
	      data: {
	        date_approved: self.date_approved,
	        amount: self.amount,
	        effective_date: self.effective_date,
	        expiration_date: self.expiration_date,
	        poc_number: self.poc_number,
	        name_of_insured: self.name_of_insured,
	        relationship_to_member: self.relationship_to_member,
	        insured_address: self.insured_address,
	        civil_status: self.civil_status,
	        date_of_birth: self.date_of_birth,
	        name_of_beneficiary: self.name_of_beneficiary,
	        date_of_death_or_incident: self.date_of_death_or_incident,
	        reason_of_death: self.reason_of_death,
	        gender: self.gender
	      }
	    }
  	end

  	def kalinga
  		{
			id: self.id,
			center_id: self.member_center,
			branch_id: self.member_branch,
			member_id: self.name_of_member,
			claim_type: "K-KALINGA",
			prepared_by: self.prepared_by,
			date_prepared: self.created_at,
			created_at: self.created_at,
	      	updated_at: self.updated_at,
			status: "pending",
	      	data: {
		        date_approved: self.date_approved,
		        amount: self.amount,
		        effective_date: self.effective_date,
		        expiration_date: self.expiration_date,
		        poc_number: self.poc_number,
		        name_of_insured: self.name_of_insured,
		        relationship_to_member: self.relationship_to_member,
		        insured_address: self.insured_address,
		        civil_status: self.civil_status,
		        date_of_birth: self.date_of_birth,
		        name_of_beneficiary: self.name_of_beneficiary,
		        date_of_death_or_incident: self.date_of_death_or_incident,
		        reason_of_death: self.reason_of_death,
		        gender: self.gender
	      	}
	    }

  	end

end
