module BillingForWriteoff
  class FetchPaymentStatus
    def initialize(config:)
      @config     = config
      @loan       = @config[:loan]
      @amount     = @config[:amount].to_f
      @date_paid  = @config[:date_paid]

      @unpaid_amortization  = @loan.amortization_schedule_entries.unpaid
      @amount_due           = @unpaid_amortization.where(
                                "due_date <= ?", @date_paid
                              ).sum("principal_balance").round(2)

      @data = {
        principal_paid: 0.00,
        interest_paid: 0.00,
        amount_due: @amount_due,
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

        if @amount > 0
          # Pay principal_balance
          if o.principal_balance >= @amount
            principal_paid += @amount
            @data[:principal_paid] += @amount
            @amount = 0.00
          elsif o.principal_balance < @amount
            principal_paid += o.principal_balance
            @data[:principal_paid] += o.principal_balance
            @amount -= o.principal_balance
          end

          @data[:amort_entries] << {
            id: o.id,
            due_date: o.due_date,
            principal_paid: principal_paid,
            interest_paid: interest_paid
          }
        end
      end

      if @amount > @loan.total_balance
        @data[:is_overpayment] = true
      end

      @data
    end
  end
end
