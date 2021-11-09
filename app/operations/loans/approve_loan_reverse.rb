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
    raise remove_subsidiary!.inspect

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
      payable_to_mba_clip = @loan_data[:accounting_entry][:credit_journal_entries].select{ |o| o[:accounting_code_id] == "af83062d-628a-4fdd-acfd-bdebe2696513" }.first
      if payable_to_mba_clip.present?
    

      end
    end

  end
end
