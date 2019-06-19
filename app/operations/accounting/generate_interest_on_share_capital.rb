module Accounting
  class GenerateInterestOnShareCapital
    def initialize(start_date:, end_date:, equity_rate:, branch_id:)
      @start_date                           = start_date.to_date
      @end_date                             = end_date.to_date
      @equity_rate                          = (equity_rate / 100)
      @previous_year                        = @start_date.year - 1
      @member                               = Member.where("status IN (?) and branch_id = ?", ["active","resigned"], branch_id)
      #@member                               = Member.where("status IN (?) and branch_id = ? and center_id = ?", ["active"], branch_id, "5c38d52f-5535-4f96-8a79-4a0eb3c2c7de")
      #@member                               = Member.find("b9f30f57-1284-4577-9f9c-87e2c5338969")
      @data                                 = {}
      @data[:details]                       = []
      @data[:total_monthly_amount]          = 0
      @data[:total_savings_distribute]      = 0
      @data[:total_cbu_distribute]          = 0
      @data[:total_equity_interest_amount]  = 0
    end
    def execute!
      last_loop = 0
      #member = @member
      @member.each do |member|
      #if member
      
        temp                        = {}
        temp[:member_id]            = member.id
        temp[:member_name]          = member.full_name
        temp[:equity_transaction]   = []
        temp[:member_total_equity]  = 0

        member_account_details = Member.find(member.id).member_accounts.where(
                                                                          account_type: "EQUITY", 
                                                                          account_subtype: "Share Capital"
                                         
                                         )
        total_member_equity = 0
        total_average_interest_amount = 0
        member_account_details.each do |member_account|
          start_date_details   = @start_date
          
          present_year = 0

          

          account_transaction_last_year = AccountTransaction.where(
                                                                    "subsidiary_id = ? and 
                                                                     extract(year from transacted_at) <= ? and
                                                                     status = ?", 
                                                                     member_account.id,
                                                                     @previous_year,
                                                                     "approved"
                                                                  )
          count_last_year = account_transaction_last_year.count
          
          if count_last_year == 0
            account_transaction_last_year_details = 0 
          else
            account_transaction_last_year_details = account_transaction_last_year.order(:transacted_at).last.data.with_indifferent_access[:ending_balance]
          end
          
          !account_transaction_last_year_details ? last_year_amount = 0 : last_year_amount = account_transaction_last_year_details
        
          monthly_amount              = 0 
          monthly_total_amount        = 0 
          monthly_final_total_amount  = 0
          while(start_date_details <= @end_date) do
            dep                           = {}
            start_date_month              = start_date_details.month
            start_date_year               = start_date_details.year
            dep[:month]                   = Date::MONTHNAMES[start_date_details.month]
            dep[:year]                    = start_date_year
            

          account_transaction = AccountTransaction.where(
                                                          "subsidiary_id = ? and 
                                                           extract(year from transacted_at) = ? and
                                                           extract(month from transacted_at) = ?", 
                                                           member_account.id,
                                                           start_date_year,
                                                           start_date_month
                                                         ).order("transacted_at ASC").last

                                                          
            
            if start_date_month == 1
              if !account_transaction
                dep[:amount] = last_year_amount
              else
                dep[:amount] = account_transaction.data.with_indifferent_access[:ending_balance]
              end
              monthly_amount  = dep[:amount]
            else
              if !account_transaction

                dep[:amount]  = monthly_total_amount
              
              else

                dep[:amount]            = account_transaction.data.with_indifferent_access[:ending_balance]
                dep[:transaction_type]  = "Deposit/Withdraw"
                monthly_amount          = dep[:amount]
              
              end
            end

            monthly_total_amount        = monthly_amount
            start_date_details          = start_date_details + 1.month
            monthly_final_total_amount  += dep[:amount].to_f.round(2)

            temp[:equity_transaction] << dep

          end #end ng month

          @data[:total_monthly_amount]        += monthly_final_total_amount
          temp[:member_total_equity]          = monthly_final_total_amount.to_f
          temp[:member_average_equity]        = (temp[:member_total_equity] / 12).round(2) 
         
          total_equity_interest_amount = (temp[:member_average_equity] * @equity_rate).round(2)
       
          temp[:total_savings_distribute]     = (total_equity_interest_amount * 0.9).round(2)
          temp[:total_cbu_distribute]         = (total_equity_interest_amount * 0.1).round(2) 

          sum_total_equity_amount = temp[:total_savings_distribute] + temp[:total_cbu_distribute]
          
          if sum_total_equity_amount > total_equity_interest_amount

            temp[:total_equity_interest_amount] = sum_total_equity_amount 
          
          else

            temp[:total_equity_interest_amount] = total_equity_interest_amount
          
          end


          
          @data[:total_savings_distribute]    += temp[:total_savings_distribute].round(2)
          @data[:total_cbu_distribute]        += (temp[:total_cbu_distribute]).round(2)



          @data[:total_equity_interest_amount] += temp[:total_equity_interest_amount].round(2)
           
           
        end #end ng member account


      @data[:details] << temp 
      end #end ng member
        
      #last_loop += total_average_interest_amount
      #raise last_loop.inspect
        #raise @data.inspect
      @data
    end
  end
end
