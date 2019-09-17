class HiipClaim < ApplicationRecord
	belongs_to :branch
	belongs_to :center
	belongs_to :member

	validates :member, presence: true
	validates :amount, numericality: { less_than_or_equal_to: 6000,  only_integer: true, message: 'Exceed amount limit' }

	def total_balance
		total_hiip = 6000.0
		self.balance = total_hiip - self.amount
	end

end
	