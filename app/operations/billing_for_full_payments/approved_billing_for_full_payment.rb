module BillingForFullPayments
  class ApprovedBillingForFullPayment
    def initialize(data_store_id:)
      @data_store =DataStore.find(data_store_id)
      @data_store_member_data = @data_store.data.select{ |s| s["status"] == "active"  }
      
      @date_approved  = ::Utils::GetCurrentDate.new(
                          config: {
                            branch: Branch.find(@data_store.meta["branch_id"])
                          }
                        ).execute!
      
      
    end
    def execute!
      @data_store_member_data.each do |dsmd|
        member_balance = dsmd["balance"].select{ |b| b["amount"] > 0  }
        member_balance.each do |mb|
          if mb["record_type"] == "WP"
            data_details = { 
                            is_withdraw_payment: true, 
                            is_fund_transfer: false, 
                            is_interest: false, 
                            is_adjustment: false, 
                            is_for_exit_age: false, 
                            is_for_loan_payments: false, 
                            accounting_entry_reference_number: nil, 
                            beginning_balance: 0.0, 
                            ending_balance: 0.0  
                          }

           account_transaction = AccountTransaction.new(
                                                         subsidiary_id: mb["member_account_id"], 
                                                         subsidiary_type: "MemberAccount", 
                                                         amount: mb["amount"], 
                                                         transacted_at: @date_approved,
                                                         status: "approved", 
                                                         data: data_details, 
                                                         transaction_type: "withdraw"  
                                                       )
            account_transaction.save!
            ::MemberAccounts::Rehash.new( member_account: MemberAccount.find(mb["member_account_id"])).execute!
            #raise mb["member_account_id"].inspect
          else

            amort_entries = []
            amortization_schedule_entry = AmortizationScheduleEntry.where(loan_id: mb["loan_id"], is_paid: nil).order(:due_date)
            
            amortization_schedule_entry.each do |ase|
              a = { id: ase.id, due_date: ase.due_date, principal_paid: ase.principal_balance, interest_paid: ase.interest_balance }
              amort_entries << a
            end

            total_principal_paid = amort_entries.sum{ |p| p[:principal_paid]}
            total_interest_paid = amort_entries.sum{ |p| p[:interest_paid]}
            amount_due = total_principal_paid.to_f + total_interest_paid.to_f
            particular = ""
            approved_by = ""
            data  = {
                      amort_entries: amort_entries,
                      total_principal_paid: total_principal_paid,
                      total_interest_paid: total_interest_paid,
                      amount_due: amount_due,
                      particular: particular,
                      approved_by: approved_by
                    }

            at = AccountTransaction.new(
                                        subsidiary_id: mb["loan_id"],
                                        subsidiary_type: "Loan",
                                        amount: mb["amount"],
                                        transaction_type: "loan_payment",
                                        transacted_at: @date_approved, 
                                        status: "approved",
                                        data: data
                                      )
            at.save!
            ::Loans::FixAmort.new(loan: Loan.find(mb["loan_id"])).execute!
              


          end

        
        end
      end

     @data_store.update(status: "approved") 


    end

  end
end
