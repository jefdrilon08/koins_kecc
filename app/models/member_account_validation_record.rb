class MemberAccountValidationRecord < ApplicationRecord
	MEMBER_CLASSIFICATION = ["RESIGNED", "DECEASED", "EXIT AGE (Cash)", "EXIT AGE (GK)"]
	
	belongs_to :member
	belongs_to :center
	belongs_to :member_account_validation

	validates :member, presence: true
	validates :resignation_date, presence: true
  
 	before_validation :load_defaults

 	has_many_attached :files

  	after_save do
    	member_account_validation.touch
  	end

  	def length_of_stay_from_date_resigned
	    recognition_date = Member.find(self.member_id).data.with_indifferent_access[:recognition_date]

	    if resignation_date.present?
			if recognition_date.present?      
			    now = self.resignation_date.to_time
			    seconds_between = (now.to_time - recognition_date.to_time).abs 
			    days_between = seconds_between / 60 / 60 / 24
			    number_of_days = days_between.floor
			    number_of_months = (days_between / 30.44).floor
			    years = (days_between / 365.242199).floor
			    months = number_of_months - (years * 12)

			    if years < 1
			        if months > 1
			          "#{months} MONTHS"
			        elsif months == 1
			          "#{months} MONTH"
			        elsif months < 1
			          if number_of_days == 1 
			            "#{number_of_days} DAY"
			          elsif number_of_days > 1
			            "#{number_of_days} DAYS"
			          elsif number_of_days < 1
			            nil          
			          end
			        end    
			    else
			        if years == 1 && months == 0 
			          "#{years} YEAR"
			        elsif years == 1 && months == 1
			          "#{years} YEAR, #{months} MONTH"
			        elsif years == 1 && months > 1
			          "#{years} YEAR, #{months} MONTHS"
			        elsif years > 1 && months > 1
			          "#{years} YEARS, #{months} MONTHS"
			        elsif years > 1 && months == 1
			          "#{years} YEARS, #{months} MONTH"
			        elsif years > 1 && months < 1
			          "#{years} YEARS"    
			        end
			    end
			else
				return nil
			end
	    end
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


