module Loans
  class ApproveLoanReverse
    def initialize(user:, loan: )
      @user =  user
    
      @loan = loan
      @loan_data = @loan.data.with_indifferent_access
      @date_approved  = ::Utils::GetCurrentDate.new(
                          config: {
                            branch: Branch.find(@loan.branch_id)
                          }
                        ).execute!
    end
    def execute!
    
    remove_subsidiary!

    reverse_status = @loan_data[:reverse_loan_details].select{ |ld| ld[:status] == "pending" }.last
    reverse_status[:status] = "approve"
    reverse_status[:date_approved] = @date_approved
    reverse_status[:user_id] = @user.full_name
    
  

    @record = ::Loans::BuildAccountingEntryForReverse.new(loan: @loan, current_user: @user).execute!
    
    configA  = {
            accounting_entry_data: @record,
            user: @user
    }
    accounting_entry  = ::Accounting::AccountingEntries::Save.new(
                            config: configA
                          ).execute!

      
    configB  = {
            accounting_entry: accounting_entry,
            user: @user
    }
    
    @accounting_entry = ::Accounting::AccountingEntries::Approve.new(
                            config: configB
                          ).execute!

  
        
    reverse_status[:refference_number] = @accounting_entry.reference_number

    @loan.update!(data: @loan_data, status: "pending")
    @loan
     
    end

    private

    def remove_subsidiary!
      insurance_subtype = ["Life Insurance Fund", "Retirement Fund", "Credit Life Insurance Plan", "Equity Value"]
      subd_remove_amount = 0
      insurance_subtype.each do |is|
      

        member_account = MemberAccount.where(member_id: @loan.member.id, account_subtype: is).last
        if is == "Credit Life Insurance Plan"
          clip_account = AccountTransaction.where("subsidiary_id = ? and data-> 'data' ->> 'id' = ?", member_account.id, @loan.id).last
          if clip_account.present?
            AccountTransaction.find(clip_account.id).destroy!
            ::MemberAccounts::Rehash.new(member_account: MemberAccount.find(member_account.id)).execute!
          end
        else
          if is == "Life Insurance Fund"
            jEntry_name = "Payable to MBA-LIF"
          elsif is == "Retirement Fund"
            jEntry_name = "Payable to MBA - RF"
          end

          if is == "Equity Value"
            acje =  @loan_data["accounting_entry"]["credit_journal_entries"].select{ |a| a[:name] == "Payable to MBA-LIF"}
            if acje.present?
              subd_remove_amount = acje.last[:amount].to_f / 2.to_f
            end
            
          else
            acje = @loan_data["accounting_entry"]["credit_journal_entries"].select{ |a| a[:name] == jEntry_name}
            if acje.present?
              subd_remove_amount = acje.last[:amount]
            end
          end
          
          if subd_remove_amount > 0

            data = { 
                    is_withdraw_payment: false, 
                    is_fund_transfer: false, 
                    is_interest: false, 
                    is_adjustment: true, 
                    is_for_exit_age: false, 
                    is_for_loan_payments: false, 
                    accounting_entry_reference_number: nil, 
                    beginning_balance: 0.0, 
                    ending_balance: 0.0, 
                    data: {}
                  }
            AccountTransaction.create!(
                                      subsidiary_id: member_account.id, 
                                      subsidiary_type: "MemberAccount", 
                                      amount: subd_remove_amount, 
                                      transaction_type: "withdraw", 
                                      transacted_at: @date_approved, 
                                      status: "approved", 
                                      data: data
                                    )
            ::MemberAccounts::Rehash.new(member_account: MemberAccount.find(member_account.id)).execute!
          end
        end
        
      end
      
      #payable_to_mba_clip = @loan_data[:accounting_entry][:credit_journal_entries].select{ |o| o[:accounting_code_id] == "af83062d-628a-4fdd-acfd-bdebe2696513" }.first
    
      #if payable_to_mba_clip.present?
    

      #end
    end

  end
end
