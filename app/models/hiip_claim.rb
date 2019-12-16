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


	def status
		if self.expiration_date_of_coverage > Date.today
			status = "active"
		else
			status = "expired"
		end
	end

end