class HiipClaim < ApplicationRecord
	belongs_to :branch
	belongs_to :center
	belongs_to :member

	validates :member, presence: true
	validates :effective_date_of_coverage, presence: true
	validates :date_admitted, presence: true
	validates :date_discharged, presence: true
	validates :reason_of_confinement, presence: true
	validates :diagnosis, presence: true
	validates :check_payee, presence: true
  validates :expiration_date_of_coverage, presence: true


	def status
		if self.expiration_date_of_coverage > Date.today
			status = "active"
		else
			status = "expired"
		end
	end

	def hiip_hash

    {
      id: self.id,
      center_id: self.center_id,
      branch_id: self.branch_id,
      member_id: self.member_id,
      claim_type: "HIIP",
      prepared_by: self.prepared_by,
      date_prepared: self.created_at,
      created_at: self.created_at,
      updated_at: self.updated_at,
      status: "pending",
      data: {
        amount: self.amount,
        certificate_number: self.policy_number,
        effective_date_of_coverage: self.effective_date_of_coverage,
        expiration_date_of_coverage: self.expiration_date_of_coverage,
        date_admitted: self.date_admitted,
        date_discharged: self.date_discharged,
        number_of_days_tobepaid: self.number_ofdays_tobepaid,
        date_of_birth: self.date_of_birth,
        age: self.age,
        reason_of_confinement: self.reason_of_confinement,
        diagnosis: self.diagnosis,
        name_of_claimant: self.check_payee,
        balance: self.balance
      }
    }
  end

end