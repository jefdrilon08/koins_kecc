module Loans
  class Reamortize
    def initialize(config:)
      @config = config

      @loan                           = @config[:loan]
      @loan_product                   = @loan.loan_product
      @amortization_schedule_entries  = @loan.amortization_schedule_entries.order(
                                          "due_date ASC"
                                        )

      # Parameters for reamortization
      @p_principal              = @config[:p_principal]
      @p_monthly_interest_rate  = @config[:p_monthly_interest_rate]
      @p_annual_interest_rate   = (@p_monthly_interest_rate * 12)
      @p_num_installments       = @config[:p_num_installments]
      @p_term                   = @config[:p_term]

      @new_result = ::Finance::Amortize.new(
                      params: {
                        principal: @p_principal,
                        annual_interest_rate:  @p_annual_interest_rate,
                        num_installments: @p_num_installments,
                        term: @p_term
                      }
                    ).execute!

      @new_amortization = @new_result[:schedule].map{ |o|
                            principal   = o[:principal].to_f.round(2)
                            interest    = o[:interest].to_f.round(2)
                            amount_due  = (principal + interest).round(2)

                            {
                              principal: principal,
                              interest: interest,
                              principal_balance: principal,
                              interest_balance: interest,
                              principal_paid: 0.00,
                              interest_paid: 0.00,
                              amount_due: amount_due,
                              is_paid: nil
                            }
                          }

      # How much should have been paid
      @should_be_principal  = @p_principal
      @should_be_interest   = 0.00

      @new_amortization.each do |o|
        @should_be_interest += o[:interest]
      end

      @should_be_dues = @should_be_principal + @should_be_interest

      # Only get the ones with no paid balances
      @unpaid_amort = @amortization_schedule_entries.unpaid.where(
                        "(principal_paid + interest_paid) = 0"
                      )

      @paid_amortization  = @loan.amortization_schedule_entries.where.not(
                              id: @unpaid_amort.pluck(:id)
                            ).order("due_date ASC")

      @principal_paid = @paid_amortization.sum(:principal_paid).round(2)
      @interest_paid  = @paid_amortization.sum(:interest_paid).round(2)
      @total_paid     = (@principal_paid + @interest_paid).to_f.round(2)

      @data = {
        loan: {
          id: @loan.id,
          pn_number: @loan.pn_number,
          monthly_interest_rate: @loan.monthly_interest_rate,
          num_installments: @loan.num_installments,
          term: @loan.term,
          principal: @loan.principal,
          interest: @loan.interest,
          principal_paid: @loan.principal_paid,
          interest_paid: @loan.interest_paid,
          principal_balance: @loan.principal_balance,
          interest_balance: @loan.interest_balance
        },
        loan_product: {
          id: @loan_product.id,
          name: @loan_product.name
        },
        original_amortization_schedule_entries: @amortization_schedule_entries,
        unpaid_amort: @unpaid_amort,
        paid_amortization: @paid_amortization,
        new_amortization: @new_amortization,
        reamortized: [],
        excess_principal_paid: 0.00,
        excess_interest_paid: 0.00,
        excess_paid: 0.00,
        remaining_principal_balance: 0.00,
        remaining_interest_balance: 0.00,
        remaining_balance: 0.00,
        should_be_principal: @should_be_principal,
        should_be_interest: @should_be_interest,
        should_be_dues: @should_be_dues
      }
    end

    def execute!
      build_reamortized_data!

      @data
    end

    private

    def build_reamortized_data!
      if @total_paid >= @should_be_dues
        @data[:excess_principal_paid] = (@should_be_principal - @principal_paid).round(2)
        @data[:excess_interest_paid]  = (@should_be_interest - @interest_paid).round(2)
        @data[:excess_paid]           = (@data[:excess_principal_paid] + @data[:excess_interest_paid]).round(2)

        # loop against new amortization and flag paid
        @new_amortization.each_with_index do |o, i|
          @new_amortization[i][:principal_balance]  = 0.00
          @new_amortization[i][:interest_balance]   = 0.00
          @new_amortization[i][:principal_paid]     = o[:principal]
          @new_amortization[i][:interest_paid]      = o[:interest]
          @new_amortization[i][:is_paid]            = true
        end
      else

        # loop against new amortization and flag paid
        buffer_principal_paid = @principal_paid
        buffer_interest_paid  = @interest_paid

        @new_amortization.each_with_index do |o, i|
          if buffer_interest_paid >= o[:interest]
            @new_amortization[i][:interest_paid]    = o[:interest] 
            @new_amortization[i][:interest_balance] = 0.00

            buffer_interest_paid -= o[:interest].to_f.round(2)
          elsif buffer_interest_paid < o[:interest]
            @new_amortization[i][:interest_paid]    = buffer_interest_paid
            @new_amortization[i][:interest_balance] = (o[:interest] - buffer_interest_paid).round(2)

            buffer_interest_paid = 0.00
          end

          if buffer_principal_paid >= o[:principal]
            @new_amortization[i][:principal_paid]   = o[:principal]
            @new_amortization[i][:principal_balance]  = 0.00

            buffer_principal_paid -= o[:principal].to_f.round(2)
          elsif buffer_principal_paid < o[:principal]
            @new_amortization[i][:principal_paid]     = buffer_principal_paid
            @new_amortization[i][:principal_balance]  = (o[:principal] - buffer_principal_paid).round(2)

            buffer_principal_paid = 0.00
          end

          if @new_amortization[i][:principal_balance] == 0.00 and @new_amortization[i][:interest_balance] == 0.00
            @new_amortization[i][:is_paid]  = true
          end
        end

        @data[:remaining_principal_balance]
        @data[:remaining_interest_balance]

        @new_amortization.each do |o|
          @data[:remaining_principal_balance] += o[:principal_balance]
          @data[:remaining_interest_balance]  += o[:interest_balance]
        end

        @data[:remaining_balance] = (@data[:remaining_principal_balance] + @data[:remaining_interest_balance]).round(2)
      end

      @data[:reamortized] = @new_amortization
    end
  end
end
