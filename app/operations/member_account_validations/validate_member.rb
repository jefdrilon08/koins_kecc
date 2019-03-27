module MemberAccountValidations
	class ValidateMember
		def initialize(config:)
			@config						   = config
	     	@member                        = @config[:member]
	     	# @resignation_date            = @config[:resignation_date]
	     	@member_account_validation     = @config[:member_account_validation]
	      	
	      	super()
	    end

	    def execute!
	      #validate_member!
	      validate_duplicate_member!
	      validate_if_member_is_already_validated_to_pending_for_appoval_for_validation!
	      validate_member_balik_kasapi!
	      # validate_resignation_date!
	      @errors
	    end

	    private

	   	def validate_member!
			@lif_member_account = @member.member_accounts.where(account_type: "INSURANCE", account_subtype: "Life Insurance Fund").first
      		@rf_member_account = @member.member_accounts.where(account_type: "INSURANCE", account_subtype: "Retirement Fund").first
	     	@data = member::GeneratememberAccountDetailsForLifAndRfForValidation.new(member: @member, lif_member_account: @lif_member_account, rf_member_account: @rf_member_account).execute!
	      
	     	@number_of_days_lapsed = @data[:lif_num_weeks_past_due] * 7	   		
	    
	     	if @number_of_days_lapsed > 45
	     		@errors[:messages] << {
		         	key: "member",
		          	message: "Member is lapsed"
		       	}
	     	end
	    end

	    def validate_if_member_is_already_validated_to_pending_for_appoval_for_validation!
	    	member_account_validation_records = MemberAccountValidationRecord.where("status = ? OR status = ? OR status = ?", "for-approval", "for-validation", "pending")
	    	member_account_validation_records.each do |rec|
	    		if rec.member.identification_number == @member.identification_number
	    			@errors[:messages] << {
		         		key: "member_account_validation_record",
		          		message: "Member's member Account is already validated"
		       		}
		    	end
	    	end
		end

		def validate_member_balik_kasapi!
	    	member_account_validation_records = MemberAccountValidationRecord.where("status = ?", "approved")
	    	member_account_validation_records.each do |rec|
	    		if rec.member.meta.nil?
	    			if rec.member.identification_number == @member.identification_number
	    				@errors[:messages] << {
		         				key: "member_account_validation_record",
		          				message: "Member's member Account is already validated"
		       				}
		    		end
		    	else
		    		member_account_validation_recordss = MemberAccountValidationRecord.where("status = ? OR status = ? OR status = ?", "for-approval", "for-validation", "pending")
		    		member_account_validation_recordss.each do |recc|
	    				if recc.member.identification_number == @member.identification_number
	    					@errors[:messages] << {
		         				key: "member_account_validation_record",
		          				message: "Member's member Account is already validated"
		       				}
		    			end
	    			end
		    	end
	    	end
		end	

		# def validate_resignation_date!
		# 	if @resignation_date.empty?
		# 		@errors << "Resignation date cant be blank"
		# 	end
		# end

	    def validate_duplicate_member!
	    	@member_account_validation.member_account_validation_records.each do |rec|
	    		if rec.member_id == @member.id
	    			@errors[:messages] << {
         				key: "member",
          				message: "Duplicate Member"
       				}
	    		end
	    	end	
	    end
	end
end