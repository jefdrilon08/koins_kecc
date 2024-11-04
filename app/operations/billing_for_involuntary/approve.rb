module BillingForInvoluntary
    class Approve
        def initialize(config:)
            @data_store                             = DataStore.find(config[:data_store])
            @current_user                           = User.find(config[:current_user])
            @data                                   = @data_store.data.with_indifferent_access
            @accounting_entry_to_transfer           = @data[:accounting_entry_transfer_savings]
            @accounting_entry_to_payments           = @data[:accounting_entry_loan_payments]
            @current_user                           = User.find(config[:current_user])
            @date                                   = ::Utils::GetCurrentDate.new(
                                                       config: {
                                                          branch: Branch.find(@data_store.meta["branch_id"])
                                                          }
                                                    ).execute!
            
        end
        def execute!
            approve_accounting_entry_for_savings!
            approved_accounting_entry_for_loan_payments!
                     

            @accounting_entry_to_transfer[:reference_number] =  @transfer_entry[:reference_number]
            @accounting_entry_to_transfer[:status]           =  @transfer_entry[:status]
            @accounting_entry_to_transfer[:approved_by]      =  @transfer_entry[:approved_by]

            @accounting_entry_to_payments[:reference_number] = @loan_payments_entry[:reference_number]
            @accounting_entry_to_payments[:status]           =   @loan_payments_entry[:status]
            @accounting_entry_to_payments[:approved_by]      = @loan_payments_entry[:approved_by]

            
            process_transfer_savings!   
            process_loan_payments!   
           

            

            @data_store[:meta]["date_approved"] = DateTime.now.to_date
            
            @data_store.update(data: {accounting_entry_transfer_savings: @accounting_entry_to_transfer, accounting_entry_loan_payments: @accounting_entry_to_payments, records: @data[:records]},status: "approved")
            
            @data_store
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
                    @total_payment = lr[:interest_balance] + lr[:principal_balance]
                    @loan = Loan.find(lr[:id])
                   
                    payment_stats = ::Loans::FetchPaymentStats.new(
                        config: {
                          loan: @loan,
                          amount: @total_payment.round(2).to_f,
                          date_paid: @loan_payments_entry[:date_posted]
                        }
                      ).execute!
                                          
                    @account_transaction = AccountTransaction.new(
                        subsidiary_id: @loan.id,
                        subsidiary_type: "Loan",
                        amount: @total_payment.round(2).to_f,
                        transaction_type: "loan_payment",
                        transacted_at: @date,
                        status: "approved"
                    )

                    @amort_data = {
                        amort_entries: [],
                        total_interest_paid: 0.00,
                        total_principal_paid: 0.00,
                        amount_due: 0.00,
                        particular:  @loan_payments_entry[:particular],
                        approved_by:  @current_user.full_name
                    }

                    @amort_data[:total_principal_paid]  = payment_stats[:principal_paid]
                    @amort_data[:total_interest_paid]   = payment_stats[:interest_paid]
                    @amort_data[:amount_due]            = payment_stats[:amount_due]
                    @amort_data[:amort_entries]         = payment_stats[:amort_entries]
                    @account_transaction.data = @amort_data
                    @account_transaction.save!


                    @amort_data[:amort_entries].each do |ae|
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
                            payment_id: @account_transaction.id,
                            payment_date: @loan_payments_entry[:date_posted],
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

                    updated_amort         = AmortizationScheduleEntry.where(loan_id: @loan.id).order("due_date DESC")
                    @loan.principal_paid  = updated_amort.sum(:principal_paid).round(2)
                    @loan.interest_paid   = updated_amort.sum(:interest_paid).round(2)
                    @loan.principal_balance = (@loan.principal - @loan.principal_paid).round(2)
                    @loan.interest_balance  = (@loan.interest - @loan.interest_paid).round(2)



                    # Setup max_active_date
                    max_active_date = @loan.max_active_date

                    if max_active_date.blank?
                        max_active_date = updated_amort.first.due_date
                    end

                    if @loan_payments_entry[:date_posted] > max_active_date
                        max_active_date = @loan_payments_entry[:date_posted]        
                    end
                    
                    
                    @loan.save!
                    if @loan.principal_balance == 0.00 and @loan.interest_balance == 0.00
                        @loan.update!(
                            date_completed: @loan_payments_entry[:date_posted],
                            status: "paid",
                            max_active_date: @loan_payments_entry[:date_posted]
                        )
                    else
                        @loan[:data]["for_writeoff"] = true
                        @loan.update!(status: "active",data: @loan[:data],max_active_date: DateTime.now.to_date)
                    end

                    @account_transaction



                    

                   

                end


                #withdraw 
                rec[:member_accounts].each do |mr|
        
                    if mr[:account_subtype] == "K-IMPOK"
                        member_account = MemberAccount.find(mr[:id])
                        ending_balance = member_account.balance.to_f - rec[:total_loan_payment].round(2).to_f
                        total_payments = rec[:total_loan_payment] 
                        if rec[:closing_fee_amount] > 0.0
                            ending_balance -= rec[:closing_fee_amount]  
                            total_payments += rec[:closing_fee_amount]
                        end 
                       
                            withdraw_account_transaction = AccountTransaction.new(
                                subsidiary_id: member_account.id,
                                subsidiary_type: "MemberAccount",
                                amount: total_payments.round(2).to_f,
                                transaction_type: "withdraw",
                                transacted_at:  @loan_payments_entry[:date_posted],
                                status: "approved",
                                data: {
                                    is_withdraw_payment: false,
                                    is_fund_transfer: false,
                                    is_interest: false,
                                    is_adjustment: false,
                                    is_for_exit_age: false,
                                    is_for_loan_payment: false,
                                    is_for_involuntary_payment: true,
                                    accounting_entry_reference_number:  @loan_payments_entry[:reference_number],
                                    beginning_balance: member_account.balance.to_f,
                                    ending_balance:  ending_balance.round(2).to_f
                                }
                            )

                            withdraw_account_transaction.save!
                            member_account.update!(balance: ending_balance)
                        
                    end

                  
                end
                
                #update member status
                 @member = Member.find(rec[:member_id])
                 @member_data = @member.data.with_indifferent_access
                 resignation_data  = {
                     type: 'involuntary',
                     code: 'B',
                     reason: 'Patuloy na hindi pagtupad sa iyong mga obligasyon bilang kasapi ng kooperatiba (halimbawa: hindi pagdalo sa mga pagpupulong, hindi pagbabayad sa tamang oras, hindi pag-iimpok, hindi paggamit ng halagang hiniram na ayon sa nakapagkasunduan, hindi pagsagot sa co-maker sa panahon na mahirapan sa pagbabayad at hindi pagkakaroon ng mabuting ugali.)',
                     accounting_reference_number: @loan_payments_entry[:date_posted]
                   }
                 resignation_records = @member_data[:resignation_records]
                 
                 if resignation_records.blank?
                     resignation_records = []
                   end
                 
                   resignation_records << {
                     branch: @member.center,
                     center: @member.branch,
                     date_resigned: @loan_payments_entry[:date_posted],
                     member_resignation_type: {
                         name: resignation_data[:type],
                         particular: {
                             code: resignation_data[:code],
                             name: resignation_data[:reason]
                         }
                     }
                   }
             
                   @member_data[:resignation]          = resignation_data
                   @member_data[:resignation_records]  = resignation_records
                   @member_data[:hide_status]  = "involuntary"
             
                   @member.update!(
                     status: "resigned",
                     date_resigned: @loan_payments_entry[:date_posted],
                     data: @member_data
                   )
             
                   # Update all member shares
                   @member.member_shares.each do |s|
                     s.update!(is_void: true)
                   end

                #update other loans of member
                member = Member.find(rec[:member_id])
                
                member_loans = Loan.where(member_id: member.id, status: "active")
                
                member_loans.each do |d|
                    loans = Loan.find(d.id)
                    loans_data = loans.data.with_indifferent_access
                    loans_data[:for_writeoff] = true
                    loans.update!(data: loans_data, max_active_date: DateTime.now.to_date)
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
            
            reference_number =  @transfer_entry[:reference_number]
        
            
            #withdraw
            @data[:records].each do |dd|
                @to_deposit_amount = 0.0
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
                        @to_deposit_amount += ma[:balance].to_f
                        #save withdrawal transaction
                        withdraw_account_transaction.save!
                        #rehash witdraw
                        ::MemberAccounts::Rehash.new(member_account: member_account).execute!

                    end
                   
                end


                    dd[:member_accounts].each do |ww|
                    #deposit
                        if ww[:account_subtype] == "K-IMPOK"
                            @member_account = MemberAccount.find(ww[:id])
                            deposit_account_transaction = AccountTransaction.new(
                                subsidiary_id: @member_account.id,
                                subsidiary_type: "MemberAccount",
                                amount:@to_deposit_amount.round(2).to_f,
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
                            #save deposit transaction
                            deposit_account_transaction.save!
                            ::MemberAccounts::Rehash.new(member_account: @member_account ).execute!
                            
                    end
                end
            end
        end
    end
end
