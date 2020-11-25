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
         @data_store  = DataStore.where(
                                        "meta->>'branch_id' = ? AND 
                                         CAST(meta->>'as_of' AS date) = ? AND 
                                         meta->>'data_store_type' = ?", 
                                         @branch.id, 
                                         @cut_off_date,
                                         "MANUAL_AGING").last

        @data_store_data = @data_store.data.with_indifferent_access
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
                       
           principal_balance_details = @data_store_data[:records].select{ 
                                                                    |o|
                                                                        o[:member][:id] == @member.id and 
                                                                        o[:id] == loan.id 
                                                                }
      
          if @accrued_type == "BLANKET"
            if loan.maturity_date.to_date < @start_date.to_date
              if loan.date_released.to_date > @start_date.to_date
              
                  principal_balance =  principal_balance_details.last[:overall_principal_balance]
                  @cut_off_status = "valid"
              else
                  principal_balance =  0.0
                  @cut_off_status = "invalid"
              end
            else
                  principal_balance =  0.0
                  @cut_off_status = "invalid"
              
            end
            
          else #individual

            if principal_balance_details.last[:num_days_par] > 0
                @cut_off_status = "invalid"
              
            else
            
                principal_balance =  principal_balance_details.last[:overall_principal_balance]
                @cut_off_status = "valid"
  
            end
            
            
          
          
          
          end
          
          total_principal_balance = principal_balance
        
          

          #accured_interest_computation
  
          if @cut_off_status == "valid"
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
            cut_off_status: @cut_off_status,
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
