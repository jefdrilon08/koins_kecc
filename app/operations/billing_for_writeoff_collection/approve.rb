module BillingForWriteoffCollection
  class Approve
    def initialize(config:)
      @config = config
      @data_store = DataStore.find(@config[:data_store])
      @data = @data_store.data.with_indifferent_access
      @accounting_entry_data = @data_store.data.with_indifferent_access[:accounting_entry]
      @records = @data[:record]	
      @user = User.find(@config[:user])
      @date = ::Utils::GetCurrentDate.new(
              config: {
                branch: @branch
                }
              ).execute!

    end

    def execute!
      insert_payment!
    end

    def insert_payment!
      enabled_member = @records.select{|y| y[:enabled] == true}
      enabled_member.each do |em|
        em[:loan_data].each do |ld|
          if ld[:enabled] == true && ld[:name] != "Withdraw Payment"
            @amort = []
            ld[:loan_amort].each do |amort|
              if amort[:total_amount] > 0 
                @amort << {
                  id: amort[:amort_id],
                  due_date: amort[:due_date],
                  principal_paid: amort[:principal_amount].to_f.round(2),
                  interest_paid: amort[:interest_amount].to_f.round(2)
                }
              end
            end
            account_transaction = AccountTransaction.new(
              amount: ld[:amount],
	      subsidiary_id: ld[:loan_id],
	      subsidiary_type: "Loan",
	      transaction_type: "loan_payment",
	      transacted_at: @date,
	      status: "approved",
	      
              data: {
	        amort_entries: @amort,
		total_interest_paid: ld[:interest_amount].to_f.round(2),
		total_principal_paid: ld[:principal_amount].to_f.round(2),
		amount_due: ld[:amount],
		particular:  @accounting_entry_data[:particular],
		approved_by: @user.full_name
	      }
            )
            account_transaction.save!
          elsif ld[:enabled] == true && ld[:name] == "Withdraw Payment"
            account_transaction = AccountTransaction.new(
              amount: ld[:amount],
	      subsidiary_id: ld[:savings_account_id],
	      subsidiary_type: "MemberAccount",
	      transaction_type: "withdraw",
	      transacted_at: @date,
	      status: "approved",
	      
              data: {
	        is_withdraw_payment: true,
                beginning_balance: 0.0,
                ending_balance: 0.0  
              }
            )
            account_transaction.save!
            ::MemberAccounts::Rehash.new(member_account: MemberAccount.find(ld[:savings_account_id]), account_transactions: nil).execute!
          end
        end
      end
    end

  end
end
 
