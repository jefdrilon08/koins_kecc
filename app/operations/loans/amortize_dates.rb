module Loans
  class AmortizeDates
    def initialize(config:)
      @config = config
      @loan   = @config[:loan]

      @first_date_of_payment  = @loan.first_date_of_payment.try(:to_date)
      @term                   = @loan.term
      @num_installments       = @loan.num_installments
      @amorts                 = @loan.amortization_schedule_entries.order("due_date ASC")
    end

    def execute!
      current_date  = @first_date_of_payment

      if @term == "weekly"
        @amorts.each do |o|
          o.update!(
            due_date: current_date
          )

          current_date =  current_date + 7.days
        end
      elsif @term == "monthly"
        @amorts.each do |o|
          o.update!(
            due_date: current_date
          )

          current_date =  current_date + 1.month
        end
      elsif @term == "semi-monthly"
        @amorts.each do |o|
          o.update!(
            due_date: current_date
          )

          current_date =  current_date + 15.days
        end
      end

      @loan
    end
  end
end
