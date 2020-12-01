module Adjustments
  module AccruedInterests
    class ApprovedAccruedInterests
      
      def initialize(config:)
        @config = config
             
        @accrued_interest_details = @config[:accrued_interest]
        @user                     = @config[:user] 
        @accrued_interest_data = @accrued_interest_details.data.with_indifferent_access
      end

      def execute!
        @accrued_interest_data[:active_loans].each do |accrued|
          if accrued[:cumputed_accrued_interest] > 0
            amortization_schedule_entries = AmortizationScheduleEntry.unpaid.where(
                                                                                  "loan_id = ? AND 
                                                                                   due_date >= ?",
                                                                                   accrued[:id],
                                                                                   @accrued_interest_details.start_date)
            if amortization_schedule_entries.any?
              loan_term = accrued[:loan_term]
              current_date  = amortization_schedule_entries.first.due_date
            
              iter          = 1
            

              amortization_schedule_entries.each do |o|
                if iter == 1
                
                  o.update!(due_date: current_date + @accrued_interest_details.number_of_moratoium_day.to_i.days)
                else
                  if loan_term == "weekly"
                    o.update!(due_date: current_date + 7.days)
                  elsif loan_term == "semi-monthly"
                    o.update!(due_date: current_date + 15.days)
                  elsif loan_term == "monthly"
                    o.update!(due_date: current_date + 30.days)
                  else
                    raise "something went wrong for term: #{loan_term}"
                  end
                end

                current_date = o.due_date
                iter = iter + 1
              end #end of amortization

            end #end of amortization schedule entry
          
            #pag save ng interest sa loan
            a = Loan.find(accrued[:id])
            accrued_interest = {
                              original_maturity_date: a.original_maturity_date,
                              total_accrued_interest: accrued[:cumputed_accrued_interest],
                              total_accrued_interest_balance: 0.0
                            
                            }
            a_data = a.data.with_indifferent_access
            a_data[:accrued_interest] = accrued_interest
            a.update(data: a_data)

          end
        end #end of accrued_interest_data[:active_loans]
        @accrued_interest_details.update!(status: "approved")    

      end

    end
  end

end
