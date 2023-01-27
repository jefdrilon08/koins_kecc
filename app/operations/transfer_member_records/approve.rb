module TransferMemberRecords
	class Approve
		def initialize(config: )
			@config = config
			@transfer_member_records = TransferMemberRecord.find(@config[:transfer_member_records])
			@user = User.find(@config[:user])
			@branch = Branch.find(@transfer_member_records["branch_id_to_transfer"])
			@branch_code  = @branch.short_name
      @cluster_code = @branch.cluster.short_name
			@data_records = @transfer_member_records.data.with_indifferent_access
			@accounting_entry_from = @data_records[:accounting_entry_from]
			@accounting_entry_to = @data_records[:accounting_entry_to]
			@date_today = ::Utils::GetCurrentDate.new(
                          config: {
                            branch: @branch
                          }
                        ).execute! 
		end

		def execute!
			update_member!
			update_loans!
			approved_entry_from!
			approved_entry_to!
			@accounting_entry_from[:reference_number] = @from_accounting_entry.reference_number
			@accounting_entry_from[:status] = @from_accounting_entry.status
			@accounting_entry_from[:approved_by] = @from_accounting_entry.approved_by
			
			@accounting_entry_to[:reference_number] = @to_accounting_entry.reference_number
			@accounting_entry_to[:status] = @to_accounting_entry.status
			@accounting_entry_to[:approved_by] = @to_accounting_entry.approved_by




			@transfer_member_records.update!(data: {accounting_entry_to: @accounting_entry_to, accounting_entry_from: @accounting_entry_from,records: @data_records[:records]},
				date_approved: @date_today)
			@transfer_member_records
		end

		def update_member!
			@branch_counter = @branch.member_counter
			@counter = 1 
			@data_records[:records].each do |rec|
				member = Member.find(rec[:member][:id])
				center = Center.find(rec[:transfer_to_center][:id])

				member.branch_id =  @transfer_member_records.branch_id_to_transfer
				if @counter == 1
				next_member_counter  = @branch_counter + @counter
				else
					next_member_counter  = @branch_counter + @counter
				end
				@counter = @counter + 1

				member_identification_number  = @cluster_code + @branch_code + next_member_counter.to_s.rjust(5, "0")
				member.identification_number = member_identification_number
				member.center = center
				member.save!
			end
		end
		
		def update_loans!
			@data_records[:records].each do |rec|
				rec[:loan_records].each do |lr|
					loan_id = lr[:loan_id]
					branch_id =  @transfer_member_records.branch_id_to_transfer
					
					loan = Loan.find(loan_id).update(center_id: rec[:transfer_to_center][:id],branch_id: branch_id,user_id: rec[:transfer_to_center][:so_id])
					
				end
			end
		end
		

		def approved_entry_from!
			config  = {
		accounting_entry_data: @accounting_entry_from.with_indifferent_access,
		user: @user
		}

		accounting_entry  = ::Accounting::AccountingEntries::Save.new(
		                    config: config
		                  ).execute!

		# Post to books
		config  = {
		accounting_entry: accounting_entry,
		user: @user
		}

		@from_accounting_entry = ::Accounting::AccountingEntries::Approve.new(
		                    config: config
		                  ).execute!
	
		@from_accounting_entry
		
		end

		def approved_entry_to!
			config  = {
		accounting_entry_data: @accounting_entry_to.with_indifferent_access,
		user: @user
		}

		accounting_entry  = ::Accounting::AccountingEntries::Save.new(
		                    config: config
		                  ).execute!

		# Post to books
		config  = {
		accounting_entry: accounting_entry,
		user: @user
		}

		@to_accounting_entry = ::Accounting::AccountingEntries::Approve.new(
		                    config: config
		                  ).execute!
	
		@to_accounting_entry
		end
	end
end