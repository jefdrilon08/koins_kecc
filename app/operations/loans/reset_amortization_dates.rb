module Loans
  class ResetAmortizationDates
    def initialize(config:)
      @config = config
      @loan   = @config[:loan]
  

      if @loan.blank?
        raise "Loan not found"
      end

      if !@loan.active?
        raise "Cannot reamortize dates of non-active loan #{@loan.id}"
      end

      @amortization_schedule_entries  = @loan.amortization_schedule_entries.order(
                                          "due_date ASC"
                                        )
    end

    def execute!
      term      = @loan.term
      due_date  = @loan.first_date_of_payment

      @amortization_schedule_entries.each do |o|
        o.update!(due_date: due_date)

        if term == "weekly"
          due_date = due_date + 1.week
        elsif term == "monthly"
          due_date = due_date + 1.month
        elsif term == "semi-monthly"
          due_date = due_date + 15.days
        else
          raise "Invalid term: #{term}"
        end
      end

      @loan
    end
  end
end
