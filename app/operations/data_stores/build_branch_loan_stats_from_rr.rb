module DataStores
  class BuildBranchLoanStatsFromRr
    def initialize(rr_data:)
      @rr_data  = rr_data

      @data = {
        loan_products: [],
        branch: @rr_data[:branch],
        as_of: @rr_data[:as_of],
        total_active_loans: 0,
        total_principal: 0.00,
        total_principal_paid: 0.00,
        total_principal_paid_due: 0.00,
        total_principal_due: 0.00,
        total_portfolio: 0.00,
        total_past_due_amount: 0.00,
        total_principal_past_due_amount: 0.00,
        total_par_amount: 0.00,
        total_par_rate: 0,
        total_rr: 0
      }

      # Loan Products
      @loan_products  = LoanProduct.all.order("priority ASC")

      @loan_products.each do |o|
        @data[:loan_products] << {
          id: o.id,
          name: o.name,
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
          rr: 0
        }
      end
    end

    def execute!
      @loan_products.each_with_index do |lp, i|
        @rr_data[:records].each do |o|
          if lp.id == o[:loan_product][:id]
            principal                 = o[:principal]
            principal_paid_due        = o[:principal_paid_due] || 0.00
            principal_due             = o[:principal_due]
            principal_paid            = o[:principal_paid]
            portfolio                 = o[:principal].to_f - o[:principal_paid].to_f
            past_due_amount           = o[:total_balance]
            principal_past_due_amount = o[:principal_balance]
            par_amount                = o[:overall_principal_balance]
            par_rate                  = o[:par]
            rr                        = o[:rr]

            @data[:loan_products][i][:active_loans]       = @data[:loan_products][i][:active_loans] + 1
            @data[:loan_products][i][:principal]          += principal.to_f.round(2)
            @data[:loan_products][i][:principal_paid]     += principal_paid.to_f.round(2)
            @data[:loan_products][i][:principal_paid_due] += principal_paid_due.to_f.round(2)
            @data[:loan_products][i][:principal_due]      += principal_due.to_f.round(2)
            @data[:loan_products][i][:portfolio]          += portfolio.to_f.round(2)
            @data[:loan_products][i][:past_due_amount]    += past_due_amount.to_f.round(2)
            @data[:loan_products][i][:principal_past_due_amount] += principal_past_due_amount.to_f.round(2)

            if(o[:num_days_par].to_i > 0)
              @data[:loan_products][i][:par_amount] += par_amount.to_f.round(2)
            end

            @data[:total_active_loans]              = @data[:total_active_loans] + 1
            @data[:total_principal]                 += principal.to_f.round(2)
            @data[:total_principal_paid]            += principal_paid.to_f.round(2)
            @data[:total_principal_paid_due]        += principal_paid_due.to_f.round(2)
            @data[:total_principal_due]             += principal_due.to_f.round(2)
            @data[:total_portfolio]                 += portfolio.to_f.round(2)
            @data[:total_past_due_amount]           += past_due_amount.to_f.round(2)
            @data[:total_principal_past_due_amount] += principal_past_due_amount.to_f.round(2)

            if(o[:num_days_par].to_i > 0)
              @data[:total_par_amount]  += par_amount.to_f.round(2)
            end
          end
        end

        # Compute RR
        if @data[:loan_products][i][:principal_paid_due] == 0.00
          @data[:loan_products][i][:rr] = 0
        else
          #@data[:loan_products][i][:rr] = (@data[:loan_products][i][:principal_paid_due] - @data[:loan_products][i][:principal_past_due_amount]) / @data[:loan_products][i][:principal_paid_due]
          @data[:loan_products][i][:rr] = (@data[:loan_products][i][:principal_paid_due] / @data[:loan_products][i][:principal_due])
        end

        # Compute PAR Rate
        @data[:loan_products][i][:par_rate]  = @data[:loan_products][i][:par_amount] / @data[:loan_products][i][:portfolio]
      end

      # Compute total par rate and total rr
      #@data[:total_par_rate]  = @data[:total_principal_past_due_amount] / @data[:total_portfolio]
      @data[:total_par_rate]  = @data[:total_par_amount] / @data[:total_portfolio]

      if @data[:total_principal_paid_due] == 0.00
        @data[:total_rr]  = 0
      else
        @data[:total_rr]  = (@data[:total_principal_paid_due] / @data[:total_principal_due])
      end

      @data[:loan_products] = @data[:loan_products].select{ |o|
                                o[:active_loans] > 0
                              }

      @data
    end
  end
end
