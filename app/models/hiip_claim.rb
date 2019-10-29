class HiipClaim < ApplicationRecord
	belongs_to :branch
	belongs_to :center
	belongs_to :member

	validates :member, presence: true
	# validates :amount, numericality: { less_than_or_equal_to: 6000,  only_integer: true, message: 'Exceed amount limit' }

	before_validation :load_defaults

	def load_defaults
		if self.member.new_record?
	      	self.balance = 6000.00 - self.amount
	    else
	      	self.balance = self.balance - self.amount
		end
	end
end