module DataStores
  class BuildBranchLoanStatsPerOfficerFromRr
    def initialize(rr_data:)
      @rr_data  = rr_data

      @data = {
        officers: []
      }

      @loan_products  = LoanProduct.all.order("priority ASC")
      @officers       = @rr_data[:records].map{ |o| o[:officer] }.uniq
    end

    def execute!
      @officers.each do |officer|
        officer_data  = {
          officer: officer,
          active_loans: 0,
          principal: 0.00,
          principal_paid: 0.00,
          principal_paid_due: 0.00,
          principal_due: 0.00,
          portfolio: 0.00,
          past_due_amount: 0.00,
          principal_past_due_amount: 0.00,
          par_amount: 0.00,
          par_rate: 0,
          rr: 0,
          loan_products: []
        }

        @loan_products.each_with_index do |lp, i|
          loan_product  = {
            id: lp.id,
            name: lp.name,
            active_loans: 0,
            principal: 0.00,
            principal_paid: 0.00,
            principal_paid_due: 0.00,
            principal_due: 0.00,
            portfolio: 0.00,
            past_due_amount: 0.00,
            principal_past_due_amount: 0.00,
            par_amount: 0.00,
            par_rate: 0,
            rr: 0,
            loans: []
          }

          loans = @rr_data[:records].select{ |o| o[:officer][:id] == officer[:id] and o[:loan_product][:id] == lp.id }

          loan_product[:active_loans] = loans.size
          loan_product[:loans]        = loans

          loans.each do |o_loan|
            principal                 = o_loan[:principal]
            principal_paid_due        = o_loan[:principal_paid_due] || 0.00
            principal_due             = o_loan[:principal_due]
            principal_paid            = o_loan[:principal_paid]
            portfolio                 = o_loan[:principal].to_f - o_loan[:principal_paid].to_f
            past_due_amount           = o_loan[:total_balance]
            principal_past_due_amount = o_loan[:principal_balance]
            par_amount                = o_loan[:overall_principal_balance]
            par_rate                  = o_loan[:par]
            rr                        = o_loan[:rr]

            loan_product[:principal]                  += principal.to_f.round(2)
            loan_product[:principal_paid]             += principal_paid.to_f.round(2)
            loan_product[:principal_paid_due]         += principal_paid_due.to_f.round(2)
            loan_product[:principal_due]              += principal_due.to_f.round(2)
            loan_product[:portfolio]                  += portfolio.to_f.round(2)
            loan_product[:past_due_amount]            += past_due_amount.to_f.round(2)
            loan_product[:principal_past_due_amount]  += principal_past_due_amount.to_f.round(2)

            if(o_loan[:num_days_par].to_i > 0)
              loan_product[:par_amount] += par_amount.to_f.round(2)
            end
          end

          # Compute RR
          if loan_product[:principal_paid_due] == 0.00
            loan_product[:rr] = 0
          else
            loan_product[:rr] = (loan_product[:principal_paid_due] / loan_product[:principal_due])
          end

          # Compute PAR Rate
          loan_product[:par_rate]  = loan_product[:par_amount] / loan_product[:portfolio]

          if loan_product[:loans].any?
            officer_data[:loan_products] << loan_product
          end
        end

        # Compute totals
        officer_data[:loan_products].each do |o|
          active_loans              = o[:active_loans]
          principal                 = o[:principal]
          principal_paid_due        = o[:principal_paid_due] || 0.00
          principal_due             = o[:principal_due]
          principal_paid            = o[:principal_paid]
          portfolio                 = o[:principal].to_f - o[:principal_paid].to_f
          past_due_amount           = o[:total_balance]
          principal_past_due_amount = o[:principal_past_due_amount]
          par_amount                = o[:par_amount]
          par_rate                  = o[:par]
          rr                        = o[:rr]

          officer_data[:active_loans]               += active_loans.to_i
          officer_data[:principal]                  += principal.to_f.round(2)
          officer_data[:principal_paid]             += principal_paid.to_f.round(2)
          officer_data[:principal_paid_due]         += principal_paid_due.to_f.round(2)
          officer_data[:principal_due]              += principal_due.to_f.round(2)
          officer_data[:portfolio]                  += portfolio.to_f.round(2)
          officer_data[:past_due_amount]            += past_due_amount.to_f.round(2)
          officer_data[:principal_past_due_amount]  += principal_past_due_amount.to_f.round(2)
          officer_data[:par_amount]                 += par_amount.to_f.round(2)
        end

        # Compute RR
        if officer_data[:principal_paid_due] == 0.00
          officer_data[:rr] = 0
        else
          officer_data[:rr] = (officer_data[:principal_paid_due] / officer_data[:principal_due])
        end

        # Compute PAR Rate
        officer_data[:par_rate]  = officer_data[:par_amount] / officer_data[:portfolio]

        @data[:officers] << officer_data
      end

      @data
    end
  end
end
