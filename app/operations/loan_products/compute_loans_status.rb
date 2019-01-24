module LoanProducts
  class ComputeLoansStatus
    def initialize(config:)
      @config = config

      @loan_product = @config[:loan_product]
      @as_of        = @config[:as_of].try(:to_date) || Date.today
      @branch       = Branch.where(id: @config[:branch_id]).first
      @center       = Center.where(id: @config[:center_id]).first

#      @paid_loans = Loan.paid.where(
#                      "date_approved <= ? AND date_completed >= ? AND loan_product_id = ?",
#                      @as_of,
#                      @as_of,
#                      @loan_product.id
#                    )
#
#      @active_loans = Loan.active.where(
#                        "loan_product_id = ? AND date_approved <= ?",
#                        @loan_product.id,
#                        @as_of
#                      )
#
#      @loans  = Loan.where(id: [@paid_loans.pluck(:id) + @active_loans.pluck(:id)])
#
#      # Filter if branch is included
#      if @config[:branch_id].present?
#        @loans  = @loans.where(branch_id: @config[:branch_id])
#      end
#
#      # Filter if center is included
#      if @config[:center_id].present?
#        @loans  = @loans.where(center_id: @config[:center_id])
#      end

      @loans  = ::Loans::FetchActiveAsOf.new(
                  config: {
                    as_of: @as_of,
                    branch: @branch,
                    loan_product: @loan_product
                  }
                ).execute!

      @payments = AccountTransaction.approved_loan_payments.where(
                    "transacted_at <= ? AND subsidiary_id IN (?) AND subsidiary_type = ?",
                    @as_of,
                    @loans.pluck(:id),
                    "Loan"
                  ).order("transacted_at ASC")

      @amorts = AmortizationScheduleEntry.where(
                  "due_date <= ? AND loan_id IN (?)",
                  @as_of,
                  @loans.pluck(:id)
                ).order("due_date ASC")

      @data = {
        as_of: @as_of,
        num_loans: @loans.size,
        num_members: @loans.pluck(:member_id).uniq.size,
        principal: @loans.sum(:principal),
        interest: @loans.sum(:interest),
        repayment_rate: nil,
        par: nil,
        principal_repayment_rate: nil,
        interest_repayment_rate: nil,
        total_principal_due: 0.00,
        total_interest_due: 0.00,
        total_due: 0.00,
        total_principal_balance: 0.00,
        total_interest_balance: 0.00,
        total_balance: 0.00,
        total_principal_portfolio: 0.00,
        total_interest_portfolio: 0.00,
        total_portfolio: 0.00,
        total_principal_paid: 0.00,
        total_interest_paid: 0.00,
        total_paid: 0.00,
        total_principal_past_due: 0.00,
        total_interest_past_due: 0.00,
        total_past_due: 0.00,
        loan_product: {
          id: @loan_product.id,
          name: @loan_product.name
        },
        loans: []
      }
    end

    def execute!
      # Compute total dues
      @data[:total_principal_due] = @amorts.sum(:principal).round(2)
      @data[:total_interest_due]  = @amorts.sum(:interest).round(2)
      @data[:total_due]           = (@data[:total_principal_due] + @data[:total_interest_due]).round(2)

      # Compute total paid
      @data[:total_principal_paid]  = @payments.sum("CAST(data->>'total_principal_paid' AS decimal)").round(2)
      @data[:total_interest_paid]   = @payments.sum("CAST(data->>'total_interest_paid' AS decimal)").round(2)
      @data[:total_paid]            = (@data[:total_principal_paid] + @data[:total_interest_paid]).round(2)

      # Compute portfolio
      @data[:total_principal_portfolio] = (@data[:principal] - @data[:total_principal_paid]).round(2)
      @data[:total_interest_portfolio]  = (@data[:interest] - @data[:total_interest_paid]).round(2)
      @data[:total_portfolio]           = (@data[:total_principal_portfolio] + @data[:total_interest_portfolio]).round(2)

      # Compute total balances
      @data[:total_principal_balance] = (@data[:total_principal_due] - @data[:total_principal_paid]).round(2)

      if @data[:total_principal_balance] < 0
        @data[:total_principal_balance] = 0.00
      end

      @data[:total_interest_balance]  = (@data[:total_interest_due] - @data[:total_interest_paid]).round(2)

      if @data[:total_interest_balance] < 0
        @data[:total_interest_balance] = 0.00
      end

      @data[:total_balance]           = (@data[:total_principal_balance] + @data[:total_interest_balance]).round(2)

      # Compute past due
      @data[:total_principal_past_due]  = @data[:total_principal_balance] > 0 ? @data[:total_principal_balance] : 0.00
      @data[:total_interest_past_due]   = @data[:total_interest_balance] > 0 ? @data[:total_interest_balance] : 0.00
      @data[:total_past_due]            = (@data[:total_principal_past_due] + @data[:total_interest_past_due]).round(2)

      # Compute repayment rate
      @data[:principal_repayment_rate]  = @data[:total_principal_paid] / @data[:total_principal_due]
      @data[:interest_repayment_rate]   = @data[:total_interest_paid] / @data[:total_interest_due]
      @data[:repayment_rate]            = @data[:total_paid] / @data[:total_due]

      # Clean repayment rates
      if @data[:principal_repayment_rate] > 1
        @data[:principal_repayment_rate] = 1
      end

      if @data[:interest_repayment_rate] > 1
        @data[:interest_repayment_rate] = 1
      end

      if @data[:repayment_rate] > 1
        @data[:repayment_rate] = 1
      end

      # Compute for PAR
      @data[:par] = @data[:total_principal_balance] / @data[:principal]

      # Include loans
      include_loans = false
      if @config[:include_loans].present?
        @data[:loans] = build_loans!
      end

      @data
    end

    private

    def build_loans!
      data  = []

      @loans.each do |loan|
        data  <<  ::Loans::ComputeStatus.new(
                    config: {
                      loan: loan,
                      as_of: @as_of
                    }
                  ).execute! 
      end

      data
    end
  end
end
