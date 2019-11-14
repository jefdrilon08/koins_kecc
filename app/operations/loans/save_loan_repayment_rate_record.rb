module Loans
  class SaveLoanRepaymentRateRecord
    def initialize(config:)
      @config = config
      @as_of  = @config[:as_of].try(:to_date)
      @loan   = @config[:loan]

      @branch = @loan.branch
      @center = @loan.center

      if @as_of.blank?
        raise "as_of required"
      end

    end

    def execute!
      if (@loan.paid? and @loan.date_approved <= @as_of and @loan.date_completed > @as_of) || (@loan.active? and @loan.date_approved <= @as_of)
        @loan_repayment_rate  = LoanRepaymentRate.where(
                                  loan_id: @loan.id,
                                  branch_id: @branch.id,
                                  center_id: @center.id,
                                  as_of: @as_of
                                ).first

        if @loan_repayment_rate.blank?
          @loan_repayment_rate  = LoanRepaymentRate.new(
                                    loan: @loan,
                                    branch: @branch,
                                    center: @center,
                                    as_of: @as_of
                                  )
        end

        @loan_repayment_rate.data = ::Reports::GenerateLoanRepaymentReport.new(
                                      config: {
                                        loan: @loan,
                                        as_of: @as_of,
                                        manual_aging: false
                                      }
                                    ).execute!

        @loan_repayment_rate.save!
      end
    end
  end
end
