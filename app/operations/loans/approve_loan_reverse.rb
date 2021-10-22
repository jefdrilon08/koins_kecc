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
  end
end
