module Loans
  class Reamortize
    def initialize(config:)
      @config = config

      @loan                           = @config[:loan]
      @loan_product                   = @loan.loan_product
      @amortization_schedule_entries  = @loan.amortization_schedule_entries.order("due_date ASC")

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
                              amount_due: amount_due
                            }
                          }

      # How much should have been paid
      @should_be_principal  = @p_principal
      @should_be_interest   = 0.00

      @new_amortization.each do |o|

      # Only get the ones with no paid balances
      @unpaid_amort = @amortization_schedule_entries.unpaid.where(
                        "(principal_paid + interest_paid) = 0"
                      )

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
        new_amortization: @new_amortization,
        reamortized: [],
        excess_principal_paid: 0.00,
        excess_interest_paid: 0.00,
        remaining_principal_balance: 0.00,
        remaining_interest_balance: 0.00
      }
    end

    def execute!
      build_reamortized_data!
      @data
    end

    private

    def build_reamortized_data!
    end
  end
end
