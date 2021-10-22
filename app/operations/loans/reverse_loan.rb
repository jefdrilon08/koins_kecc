module Loans
  class ReverseLoan
    
    def initialize(user:, loan: )
      @loan = loan
      @user = user
      @loan_data = @loan.data.with_indifferent_access
    
      @date_create  = ::Utils::GetCurrentDate.new(
                          config: {
                            branch: Branch.find(@loan.branch_id)
                          }
                        ).execute!
    
      
    end
    def execute!
      if @loan_data["reverse_loan_details"].present?
        @loan_data["reverse_loan_details"] << { reason: "", date_reversed: @date_create, status: "pending",  user_id: "", date_approved: "", type: "reverse", refference_number: ""  }
      else
        @loan_data["reverse_loan_details"] = []
        @loan_data["reverse_loan_details"] << { reason: "", date_reversed: @date_create, status: "pending",  user_id: "", date_approved: "", type: "reverse", refference_number: ""  }
      end

      @loan.update!(data:  @loan_data)

      @loan


    end

  end
end
