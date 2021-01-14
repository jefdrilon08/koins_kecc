module Adjustments
  module RecomputeRestructures
    class Approve
      def initialize(config:)
        @config = config
        @recompute_restructure_details =  @config[:recompute_restructure]
        
        @loan = Loan.find(@recompute_restructure_details.loan)
        @current_date  = ::Utils::GetCurrentDate.new(config: { branch: @loan.branch }).execute!
        @amount = @loan.principal - @recompute_restructure_details.data["loans"].last["total_loanable_amount"]
        

         
      end
      def execute!



        if @loan.status == "active"
          raise "jef".inspect
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


  
        raise @account_transaction.inspect

      end
    end
  end
end
