module Adjustments
  module RecomputeRestructures
    class Approve
      def initialize(config:)
        @config = config
        @user = @config[:user_full_name]
        @recompute_restructure_details =  @config[:recompute_restructure]
        
        @loan = Loan.find(@recompute_restructure_details.loan)
        @current_date  = ::Utils::GetCurrentDate.new(config: { branch: @loan.branch }).execute!
        @amount = @loan.principal - @recompute_restructure_details.data["loans"].last["total_loanable_amount"]
        

         
      end
      def execute!

        if @loan.status == "active"
          amort_entries = []
          total_distribute = @amount
          amort_amount = 0
          amount = @amount
            
          @account_transaction  = AccountTransaction.new(
                                    subsidiary_id: @recompute_restructure_details.loan,
                                    subsidiary_type: "Loan",
                                    amount: @amount,
                                    transaction_type: "loan_payment",
                                    transacted_at: @current_date,
                                    status: "approved",
                                    data: {}
                                  )
          AmortizationScheduleEntry.where(loan_id: @recompute_restructure_details.loan, is_paid: nil).order(:due_date).each do |ase|
            amort_amount = ase.principal_balance + ase.interest_balance
            if amount > 0 
              if amount >= amort_amount 
                test = amort_amount
                for_principal = test - ase.interest_balance
                amount  = amount - test
                
                @payments = { id: ase.id, due_date: ase.due_date, principal_paid: for_principal, interest_paid: ase.interest_balance }
                amort_amount = amort_amount + test
              else
                #raise amort_amount.to_f.inspect
                if amount > 0
                  test = amount
                  if ase.interest_balance != 0
                      for_interest = amount - ase.interest_balance
                      if for_interest < 0
                        total_interest = test
                        for_principal = 0.0
                      else
                        total_interest = ase.interest_balance
                        for_principal = test - ase.interest_balance
                      end
                      
                      
                      

                    
                  end
                  amount = amount - amount
                  @payments = { id: ase.id, due_date: ase.due_date,principal_paid: for_principal, interest_paid: total_interest }
                
                end
            end
            
          
              amort_entries << @payments
            end
            
          end
          
            
          @account_transaction.data[:amort_entries] = amort_entries
          total_interest_paid = amort_entries.sum{ |h| h[:interest_paid]  }
          total_principal_paid = amort_entries.sum{ |h| h[:principal_paid]  }
          @account_transaction.data[:total_interest_paid] =  total_interest_paid
          @account_transaction.data[:total_principal_paid] =  total_principal_paid

          @account_transaction.data[:amount_due] =  total_interest_paid + total_principal_paid
          @account_transaction.data[:particular] =  "To record rebates of member's for k-sagip installement on old policy"
          @account_transaction.data[:approved_by] =  @user
          
          @account_transaction.save!
          ::Loans::FixAmort.new(loan: Loan.find(@recompute_restructure_details.loan)).execute!  
          @recompute_restructure_details.update(status: "approved")
        
        else
          
          @account_transaction  = AccountTransaction.new(
                                    subsidiary_type: "MemberAccount",
                                    amount: @amount,
                                    transaction_type: "deposit",
                                    transacted_at: @current_date,
                                    status: "approved"
                                  )
          @data = {
            is_withdraw_payment: false,
            is_fund_transfer: false,
            is_interest: false,
            is_adjustment: false,
            is_for_exit_age: false,
            is_for_loan_payments: false,
            beginning_balance: 0.00,
            ending_balance: 0.00
          }
                              
          
          if @loan.member.member_type == "GK"
            @savings_account_id = MemberAccount.where(member_id: @loan.member_id, account_subtype: "Golden K")
            @account_transaction.subsidiary_id = @savings_account_id.last.id
          else
            @savings_account_id = MemberAccount.where(member_id: @loan.member_id, account_subtype: "K-IMPOK")
            @account_transaction.subsidiary_id = @savings_account_id.last.id
            
          end
          @account_transaction.data = @data

          @account_transaction.save!
        
          ::MemberAccounts::Rehash.new(
            member_account: @savings_account_id.last
          ).execute!

          rRestract = RecomputeRestructure.find(@recompute_restructure_details.id).update(status: "approved",transaction_date: @current_date)  
        end #end of active


  
        @account_transaction

      end
    end
  end
end
