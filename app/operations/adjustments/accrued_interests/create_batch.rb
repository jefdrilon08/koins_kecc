module Adjustments
  module AccruedInterests
    class CreateBatch
    def initialize(config:)
        @config         = config

        @branch                   = @config[:branch]
        @center                   = @config[:center]
        @cut_off_date             = @config[:cut_off_date]
        @start_date               = @config[:start_date]
        @end_date                 = @config[:end_date]
        @number_of_days           = ((@end_date.to_date - @start_date.to_date).to_f / 365 * 12).round
        @accrued_type             = @config[:accrued_type]
        @number_of_moratorium_day = @config[:number_of_moratorium_days]
      
      
        @accrued_interest = AccruedInterest.new(
                              branch: @branch,
                              center: @center,
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
      @data_store_data[:records].each do |record|
        loan = Loan.find(record[:id])
        
        if loan.status == "active"
          raise record[:maturity_date].inspect
          if record[:maturity_date].to_date < @start_date.to_date
            if record[:date_released] > @start_date.to_date
              principal_balance = record[:overall_principal_balance].to_f
              @cut_off_status = "invalid"
              
              compute_accrued_interest = (((principal_balance.to_f * (loan.monthly_interest_rate.to_f * 100 ) / 2.to_f).round(2).to_f * @number_of_days.to_i) / 100).round(2)

              @accrued_interest.data["active_loans"] << {
                id: loan.id,
                pn_number: loan.pn_number,
                principal_balance: principal_balance,
                loan_term: loan.term,
                cut_off_status: @cut_off_status,
                cumputed_accrued_interest: compute_accrued_interest,
                loan_product: {
                  id: record[:id],
                  name: record[:loan_product][:name]
                }

        
              }
            end
          end
             
        end

      end
      

    end
    end
  end
end
