module Loans
  class CreateNewPayment
    def initialize(config:)
      @config = config

      @loan           = @config[:loan]
      @amount         = @config[:amount]
      @amount_due     = @config[:amount]
      @transacted_at  = @config[:transacted_at]
      @persist        = @config[:persist]
      @particular     = @config[:particular]
      @unpaid_amort   = AmortizationScheduleEntry.where(
                          loan_id: @loan.id, 
                          is_paid: nil
                        ).order("due_date ASC")

      if !@loan.active?
        raise "Loan #{@loan.id} is not active. Status: #{@loan.status}"
      end
    end

    def execute!
      transaction = AccountTransaction.new(
                      amount: @amount,
                      subsidiary: @loan,
                      subsidiary_type: "Loan",
                      transaction_type: "loan_payment",
                      transacted_at: @transacted_at,
                      data: {}
                    )

      # interest first
      total_interest_paid   = 0.00
      total_principal_paid  = 0.00
      amort_entries         = []

      @unpaid_amort.each do |amort|
        if @amount > 0
          interest_paid   = 0.00
          principal_paid  = 0.00
          
          if amort.interest_balance <= @amount && @amount != 0 && amort.interest_balance != 0
            interest_paid +=  amort.interest_balance
            @amount       -=  amort.interest_balance

            amort_entries << {
              id: amort.id,
              interest_paid: interest_paid.to_f,
              principal_paid: 0.00,
              due_date: amort.due_date.strftime("%B %d, %Y"),
            }
          elsif @amount < amort.interest_balance && @amount != 0 && amort.interest_balance != 0
            interest_paid += @amount
            @amount       = 0

            amort_entries << {
              id: amort.id,
              interest_paid: interest_paid.to_f,
              principal_paid: 0.00,
              due_date: amort.due_date.strftime("%B %d, %Y"),
            }
          end

          if amort.principal_balance <= @amount && @amount != 0 && amort.principal_balance != 0
            principal_paid  +=  amort.principal_balance
            @amount         -=  amort.principal_balance

            amort_entries << {
              id: amort.id,
              interest_paid: 0.00,
              principal_paid: principal_paid.to_f,
              due_date: amort.due_date.strftime("%B %d, %Y"),
            }
          elsif @amount < amort.principal_balance && @amount != 0 && amort.principal_balance != 0
            principal_paid += @amount
            @amount       = 0

            amort_entries << {
              id: amort.id,
              interest_paid: 0.00,
              principal_paid: principal_paid.to_f,
              due_date: amort.due_date.strftime("%B %d, %Y"),
            }
          end

          total_interest_paid   +=  interest_paid
          total_principal_paid  +=  principal_paid
        end
      end

      amort_entries = flatten_amort_entries(amort_entries)

      transaction.data["amort_entries"]         = amort_entries
      transaction.data["total_interest_paid"]   = total_interest_paid.to_f
      transaction.data["total_principal_paid"]  = total_principal_paid.to_f
      transaction.data["amount_due"]            = @amount_due
      transaction.data["particular"]            = @particular

      if @persist
        transaction.save!
      end

      transaction
    end

    private

    def flatten_amort_entries(amort_entries)
      temp  = []
      amort_ids = []
      amort_entries.each do |amort_entry|
        if !amort_ids.include?(amort_entry[:id])
          amort_ids << amort_entry[:id]
        end
      end

      amort_ids.each do |id|
        temp_entries  = amort_entries.select { |k| k[:id] == id }
        principal_paid = 0.00
        interest_paid  = 0.00

        temp_entries.each do |te|
          principal_paid += te[:principal_paid]
          interest_paid += te[:interest_paid]
        end

        temp  <<  {
          id: id,
          due_date: AmortizationScheduleEntry.find(id).due_date.strftime("%B %d, %Y"),
          principal_paid: principal_paid,
          interest_paid: interest_paid
        }
      end

      temp
    end
  end
end
