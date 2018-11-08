module Loans
  class FetchPaymentStats
    def initialize(config:)
      @config     = config
      @loan       = @config[:loan]
      @amount     = @config[:amount]
      @date_paid  = @config[:date_paid]

      @unpaid_amortization  = @loan.amortization_schedule_entries.unpaid

      @data = {
        principal_paid: 0.00,
        interest_paid: 0.00,
        amount: @amount,
        date_paid: @date_paid,
        is_overpayment: false,
        amort_entries: []
      }
    end

    def execute!
      @unpaid_amortization.each do |o|
        principal_paid  = 0.00
        interest_paid   = 0.00
        due_date        = o.due_date

        # Pay interest_balance
        if @amount > 0
          if o.interest_balance > @amount
            interest_paid += @amount
            @data[:interest_paid] += (o.interest_balance - @amount)
            @amount = 0.00
          elsif o.interest_balance < @amount
            interest_paid += o.interest_balance
            @data[:interest_paid] += o.interest_balance
            @amount -= o.interest_balance
          end

          # Pay principal_balance
          if o.principal_balance > @amount
            principal_paid += (o.principal_paid - @amount)
            @data[:principal_paid] += (o.principal_paid - @amount)
            @amount = 0.00
          elsif o.principal_balance < @amount
            principal_paid += @amount
            @data[:principal_paid] += o.principal_balance
            @amount -= o.principal_balance
          end

          if @amount >= 0.00
            @data[:amort_entries] << {
              id: o.id,
              due_date: o.due_date,
              principal_paid: principal_paid,
              interest_paid: interest_paid
            }
          end
        end
      end

      if @amount > @loan.total_balance
        @data[:is_overpayment] = true
      end

      @data
    end
  end
end
