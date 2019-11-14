class HiipClaim < ApplicationRecord
	belongs_to :branch
	belongs_to :center
	belongs_to :member

	validates :member, presence: true
	validates :effective_date_of_coverage, presence: true
	validates :number_ofdays_tobepaid, presence: true
	
	def status
		if self.expiration_date_of_coverage > Date.today
			status = "active"
		else
			status = "expired"
		end
	end

end