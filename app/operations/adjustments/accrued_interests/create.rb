module Adjustments
  module AccruedInterests
    class Create
      def initialize(config:)
        @config         = config

        @branch                   = @config[:branch]
        @center                   = @config[:center]
        @cut_off_date             = @config[:cut_off_date]
        @start_date               = @config[:start_date]
        @end_date                 = @config[:end_date]
        #@number_of_days           = (@end_date.to_date - @start_date.to_date).to_i
        @number_of_days           = ((@end_date.to_date - @start_date.to_date).to_f / 365 * 12).round
        @accrued_type             = @config[:accrued_type]
        @member                   = @config[:member]
        @loans                    = @config[:loans]
        @number_of_moratorium_day = @config[:number_of_moratorium_days]
      

        @accrued_interest = AccruedInterest.new(
                              branch: @branch,
                              center: @center,
                              member: @member.id,
                              cut_off_date: @cut_off_date,
                              start_date: @start_date,
                              end_date: @end_date,
                              number_of_days: @number_of_days,
                              accrued_type: @accrued_type,
                              number_of_moratoium_day: @number_of_moratorium_day,
                              status: "pending",
                              data: {
                                active_loans: []
                              }


        
                            )
      end
      def execute!
        build_active_loans!

        @accrued_interest.save!

        @accrued_interest
        #raise @accrued_interest.inspect
      end

      def build_active_loans!
        
        @loans.each do |loan|
          loan_product = loan.loan_product

          if loan.date_approved.to_date < @cut_off_date.to_date || loan.maturity_date.to_date = @cut_off_date.to_date
            cut_off_status = "valid"
          else
            cut_off_status = "invalid"
          end
      
          if @accrued_type == "BLANKET"



            amortization_details_for_cut_off_paid = AmortizationScheduleEntry.where("
                                                                loan_id = ? and
                                                                due_date >= ?  and
                                                                due_date <= ?",
                                                                loan.id,@start_date,@end_date).order(:due_date)
              
            amortization_details = AmortizationScheduleEntry.where("
                                                                loan_id = ? and
                                                                due_date >= ?  and
                                                                due_date <= ? and
                                                                is_paid is null",
                                                                loan.id,@start_date,@end_date).order(:due_date)

            
            if amortization_details_for_cut_off_paid.count > 0            
              if amortization_details_for_cut_off_paid.last.is_paid == nil #nov142020
           
                  principal_balance = amortization_details.sum(:principal_balance).to_f
                  #principal_balance = amortization_details.sum(:principal).to_f

        
              else

                last_payment_date = amortization_details_for_cut_off_paid.last.data["payments"].last["payment_date"]
                if last_payment_date.to_date > @cut_off_date.to_date
                  principal_balance = amortization_details_for_cut_off_paid.sum(:principal_balance).to_f
                else
                  principal_balance = amortization_details.sum(:principal_balance).to_f
                end
      
              end #end-nov142020
            else
              principal_balance = 0.0
            end




          else #individual
            
            amortization_details = AmortizationScheduleEntry.where("
                                                                loan_id = ? and
                                                                due_date >= ?  and
                                                                due_date <= ?",
                                                                loan.id,@start_date,@end_date).order(:due_date)
            

            if amortization_details.first.is_paid == nil
              
              principal_balance = 0.0
              cut_off_status = "invalid"
            
            else

              first_payment_date = amortization_details_for_cut_off_paid.last.data["payments"].last["payment_date"]
              
              if first_payment_date <= @start_date

                if amortization_details.count > 0
                  principal_balance = amortization_details.sum(:principal_balance).to_f
                else
                  principal_balance = 0.0
                end

              else

                principal_balace = 0.0
                cut_off_status = "invalid"

              end #end of first_payment_date 
            
            end #end of amort_details 
          
          
          
          end
          
          total_principal_balance = principal_balance
        
          

          #accured_interest_computation
          if cut_off_status == "valid"
            #raise ((loan.monthly_interest_rate.to_f * 100 ) / 2.to_f).round(2).to_f.inspect
            
            compute_accrued_interest = (((total_principal_balance.to_f * (loan.monthly_interest_rate.to_f * 100 ) / 2.to_f).round(2).to_f * @number_of_days.to_i) / 100).round(2)
          else
            compute_accrued_interest = 0.0
          end

          @accrued_interest.data["active_loans"] << {
            id: loan.id,
            pn_number: loan.pn_number,
            principal_balance: principal_balance,
            loan_term: loan.term,
            cut_off_status: cut_off_status,
            cumputed_accrued_interest: compute_accrued_interest,
            loan_product: {
              id: loan_product.id,
              name: loan_product.name
            }
        
          }
        end
      end
    end
  end
end
