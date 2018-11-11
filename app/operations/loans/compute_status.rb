module Loans
  class ComputeStatus
    def initialize(config:)
      @config = config

      @loan         = @config[:loan]
      @loan_product = @loan.loan_product
      @member       = @loan.member
      @as_of        = @config[:as_of].try(:to_date) || Date.today
      @branch       = @loan.branch
      @center       = @member.center
      @cluster      = @branch.cluster
      @area         = @cluster.area

      @amorts = AmortizationScheduleEntry.where(
                  "due_date <= ? AND loan_id = ?",
                  @as_of,
                  @loan.id
                ).order("due_date ASC")

      @payments = AccountTransaction.approved_loan_payments.where(
                    "transacted_at <= ? AND subsidiary_id = ? AND subsidiary_type = ? AND amount > 0",
                    @as_of,
                    @loan.id,
                    "Loan"
                  ).order("transacted_at ASC")

      @data = {
        as_of: @as_of,
        loan_id: @loan.id,
        principal: @loan.principal.to_f.round(2),
        interest: @loan.interest.to_f.round(2),
        loan_product: {
          id: @loan_product.id,
          name: @loan_product.name
        },
        area: {
          id: @area.id,
          name: @area.name
        },
        cluster: {
          id: @cluster.id,
          name: @cluster.name
        },
        branch: {
          id: @branch.id,
          name: @branch.name
        },
        center: {
          id: @center.id,
          name: @center.name
        },
        member: {
          id: @member.id,
          first_name: @member.first_name,
          last_name: @member.last_name
        },
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
        total_principal_paid: 0.00,
        total_interest_paid: 0.00,
        total_paid: 0.00,
        total_principal_past_due: 0.00,
        total_interest_past_due: 0.00,
        total_past_due: 0.00,
        principal: @loan.principal
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

      # Compute total balances
      @data[:total_principal_balance] = (@data[:total_principal_due] - @data[:total_principal_paid]).round(2)
      @data[:total_interest_balance]  = (@data[:total_interest_due] - @data[:total_interest_paid]).round(2)
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

      return @data
    end
  end
end
