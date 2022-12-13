class TransferSavingsRecord < ApplicationRecord

	STATUSES  = [
	 "pending",
	 "approved",
	 "processing"
	]
  
	def approved?
		self.status == "approved"
	end

	def pending?
		self.status == "pending"
	end

end
