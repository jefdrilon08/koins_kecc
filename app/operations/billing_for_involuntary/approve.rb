module BillingForInvoluntary
    class Approve
        def initialize(config:)
            @data_store = DataStore.find(config[:data_store])
            @current_user = User.find(config[:current_user])
            @data = @data_store.data.with_indifferent_access
            @accounting_entry_to_transfer = @data[:accounting_entry_transfer_savings]
            @accounting_entry_to_payments = @data[:accounting_entry_loan_payments]
            @current_user = User.find(config[:current_user])
        end
        def execute!
            #approve_accounting_entry_for_savings!
            #process_transfer_savings!


            
            #approved_accounting_entry_for_loan_payments!
            process_loan_payments!
                


        end

        def approved_accounting_entry_for_loan_payments!
            config  = {
                accounting_entry_data: @accounting_entry_to_payments.with_indifferent_access,
                user: @current_user
            }

            accounting_entry  = ::Accounting::AccountingEntries::Save.new(config: config).execute!
            
            config  = {
                accounting_entry: accounting_entry,
                user: @current_user
            }

            @loan_payments_entry = ::Accounting::AccountingEntries::Approve.new(config: config).execute!
            @loan_payments_entry
        
        end

        def process_loan_payments!
            @data[:records].each do |rec|
                rec[:loan_records].each do |lr|
                    loan = Loan.find(lr[:id])
                        
                end
            end
        end

        def approve_accounting_entry_for_savings!
            config  = {
                accounting_entry_data: @accounting_entry_to_transfer.with_indifferent_access,
                user: @current_user
            }

            accounting_entry  = ::Accounting::AccountingEntries::Save.new(config: config).execute!
            
            config  = {
                accounting_entry: accounting_entry,
                user: @current_user
            }

            @transfer_entry = ::Accounting::AccountingEntries::Approve.new(config: config).execute!
            @transfer_entry           
        end
        def process_transfer_savings!
            #
            reference_number =  @transfer_entry[:reference_number]
            @data[:records].each do |dd|
                dd[:member_accounts].each do |ma|
                    if ma[:account_subtype] == "K-IMPOK"
                        @to_received_account_id = ma[:id]           
                    end
                end
            end

            @member_account = MemberAccount.find(@to_received_account_id)
            #withdraw
            @data[:records].each do |dd|
                dd[:member_accounts].each do |ma|
                    if ma[:account_subtype] != "K-IMPOK"
                        member_account = MemberAccount.find(ma[:id])
                        ending_balance = member_account.balance.to_f - ma[:balance] 
                        withdraw_account_transaction = AccountTransaction.new(
                            subsidiary_id: member_account.id,
                            subsidiary_type: "MemberAccount",
                            amount: ma[:balance].round(2).to_f,
                            transaction_type: "withdraw",
                            transacted_at: @transfer_entry[:date_posted],
                            status: "approved",
                            data: {
                                is_withdraw_payment: false,
                                is_fund_transfer: false,
                                is_interest: false,
                                is_adjustment: false,
                                is_for_exit_age: false,
                                is_for_loan_payment: false,
                                is_for_involuntary_payment: true,
                                accounting_entry_reference_number: reference_number,
                                beginning_balance: member_account.balance.to_f,
                                ending_balance:  ending_balance.round(2).to_f
                            }
                            )

                        deposit_account_transaction = AccountTransaction.new(
                            subsidiary_id: @to_received_account_id,
                            subsidiary_type: "MemberAccount",
                            amount: ma[:balance].round(2).to_f,
                            transaction_type: "deposit",
                            transacted_at: @transfer_entry[:date_posted],
                            status: "approved",
                            data: {
                                is_withdraw_payment: false,
                                is_fund_transfer: false,
                                is_interest: false,
                                is_adjustment: false,
                                is_for_exit_age: false,
                                is_for_loan_payment: false,
                                is_for_involuntary_payment: true,
                                accounting_entry_reference_number: reference_number,
                                beginning_balance: 0.0,
                                ending_balance:  0.0
                            }
                        )
                        #save withdrawal transaction
                        withdraw_account_transaction.save!
                        #rehash witdraw
                        ::MemberAccounts::Rehash.new(member_account: member_account).execute!
                        
                        #save deposit transaction
                        deposit_account_transaction.save!
                        ::MemberAccounts::Rehash.new(member_account: @member_account).execute!
                        

                    end
                end
            end
        end
    end
end