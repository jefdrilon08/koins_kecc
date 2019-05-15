module Loans
  class GenerateReamortizationAdjustment
    def initialize(config:)
      @config       = config
      @loan         = @config[:loan]
      @user         = @config[:user]

      @p_principal              = @config[:p_principal]
      @p_monthly_interest_rate  = @config[:p_monthly_interest_rate]
      @p_annual_interest_rate   = (@p_monthly_interest_rate * 12)
      @p_num_installments       = @config[:p_num_installments]
      @p_term                   = @config[:p_term]

      @adjustment_type = "reamortization"

      @meta = {
        date_generated: Date.today,
        generated_by: @user,
        loan_id: @loan.id
      }
    end

    def execute!
      @data = ::Loans::Reamortize.new(
                config: {
                  loan: @loan,
                  p_principal: @p_principal,
                  p_monthly_interest_rate: @p_monthly_interest_rate,
                  p_num_installments: @p_num_installments,
                  p_term: @p_term
                }
              ).execute!

      @adjustment_record  = AdjustmentRecord.new(
                              adjustment_type: @adjustment_type,
                              status: "pending",
                              meta: @meta,
                              data: @data
                            )

      @adjustment_record.save!

      @adjustment_record
    end
  end
end
