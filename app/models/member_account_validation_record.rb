class MemberAccountValidationRecord < ApplicationRecord
	MEMBER_CLASSIFICATION = ["RESIGNED", "DECEASED", "EXIT AGE (Cash)", "EXIT AGE (GK)"]
	
	belongs_to :member
	belongs_to :center
	belongs_to :member_account_validation

	validates :member, presence: true
	validates :resignation_date, presence: true
  
 	before_validation :load_defaults

  	after_save do
    	member_account_validation.touch
  	end

	def load_defaults
		if self.new_record?
	  		self.status = "pending"
		end
	end

	def pending?
		self.status == "pending"
	end

	def approved?
		self.status == "approved"
	end

	def is_void?
		self.data.with_indifferent_access[:is_void] == true
	end
end


