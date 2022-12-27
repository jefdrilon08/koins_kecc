module BillingForWriteoff
  class Approve
   
	def initialize(config: )
	    @config  = config
	    @data_store = DataStore.find(@config[:record])
	    @accounting_entry_data = @data_store.data.with_indifferent_access[:accounting_entry]
	    @records = @data_store.data.with_indifferent_access[:record]
	
	    @user = User.find(@config[:user])
	    @date = ::Utils::GetCurrentDate.new(
                          config: {
                            branch: @branch
                          }
                        ).execute!

	end

	def execute!
		insert_payment!
		update_member!
		approved_entry!
		# Update accounting entry with reference number
		@accounting_entry_data[:reference_number] = @accounting_entry.reference_number
		@accounting_entry_data[:status]           = @accounting_entry.status
		@accounting_entry_data[:approved_by]      = @accounting_entry.approved_by 	
		@data_store.meta[:date_approved] = @date
		@data_store.update!(status: "approved",data: {accounting_entry: @accounting_entry_data, record: @records})
		@data_store
	end
	  
	def insert_payment!
		@records.each do |rec|
			loan =  Loan.find(rec[:loan][:loan_id])
				loan.update!(status: "writeoff")
				loan.save!

		end
	end

	def approved_entry!
		config  = {
		accounting_entry_data: @accounting_entry_data.with_indifferent_access,
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

		@accounting_entry = ::Accounting::AccountingEntries::Approve.new(
		                    config: config
		                  ).execute!

		@accounting_entry
	end

	def update_member!
		@records.each do |rec|
			member_id = rec[:member][:id]
			Member.find(member_id).update(status: "writeoff")
		end
	end

  end
end
