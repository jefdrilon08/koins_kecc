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
			amount  =  rec[:amount]
			payment_stats = ::BillingForWriteoff::FetchPaymentStatus.new(
			config: {
			loan: loan,
			amount: amount,
			date_paid: @date
			}
			).execute!


			account_transaction  = AccountTransaction.new(
			amount: amount,
			subsidiary_id: loan.id,
			subsidiary_type: "Loan",
			transaction_type: "loan_payment",
			transacted_at: @date,
			status: "approved"
			)

			data = {
			amort_entries: payment_stats[:amort_entries],
			total_interest_paid: 0.0,
			total_principal_paid: payment_stats[:principal_paid],
			amount_due: payment_stats[:amount_due],
			particular:  @accounting_entry_data[:particular],
			approved_by: @user.full_name
			}


			account_transaction.data = data
			account_transaction.save!

				data[:amort_entries].each do |ae|
					amort = AmortizationScheduleEntry.find(ae[:id])

					principal_paid  = amort.principal_paid
					interest_paid   = amort.interest_paid

					principal_balance = amort.principal_balance
					interest_balance  = amort.interest_balance

					is_paid = amort.is_paid

					data  = amort.data.try(:with_indifferent_access)

					if data.blank?
					data  = {
					payments: []
					}
					end

					data[:payments] << {
					payment_id: account_transaction.id,
					payment_date: @date,
					principal_paid: ae[:principal_paid],
					interest_paid: ae[:interest_paid]
					}

					# Compute new principal_paid, interest_paid, principal_balance, interest_balance
					principal_paid  += ae[:principal_paid].try(:to_f).round(2)
					interest_paid   += ae[:interest_paid].try(:to_f).round(2)

					principal_balance = (amort.principal - principal_paid).round(2)
					interest_balance  = (amort.interest - interest_paid).round(2)

					# Check if we're paid
					if principal_balance == 0.00 && interest_balance == 0.00
					is_paid = true
					end

					# Update this amort
					amort.principal_paid    = principal_paid
					amort.interest_paid     = interest_paid
					amort.principal_balance = principal_balance
					amort.interest_balance  = interest_balance
					amort.is_paid           = is_paid
					amort.data              = data
					amort.save!
				end
				# Update loan balances
				updated_amort         = AmortizationScheduleEntry.where(loan_id: loan.id).order("due_date DESC")
				loan.principal_paid  = updated_amort.sum(:principal_paid).round(2)
				loan.interest_paid   = updated_amort.sum(:interest_paid).round(2)

				loan.principal_balance = (loan.principal - loan.principal_paid).round(2)
				loan.interest_balance  = (loan.interest - loan.interest_paid).round(2)

				# Setup max_active_date
				max_active_date = loan.max_active_date

				if max_active_date.blank?
				max_active_date = updated_amort.first.due_date
				end

				if @date > max_active_date
				max_active_date = @date     
				end
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
