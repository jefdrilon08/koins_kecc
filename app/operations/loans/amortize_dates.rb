module Loans
  class AmortizeDates
    def initialize(config:)
      @config = config
      @loan   = @config[:loan]

      @first_date_of_payment  = @loan.first_date_of_payment.try(:to_date)
      @term                   = @loan.term
      @num_installments       = @loan.num_installments
      @amorts                 = @loan.amortization_schedule_entries
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
        @amorts.each_with_index do |o, i|
          due_day = i.even? ? 15 : current_date.end_of_month.day
          due_date = current_date.change(day: due_day)
          o.update!(due_date: due_date)
          current_date = current_date.next_month if i.odd?
        end
        #@amorts.each do |o|
        #  o.update!(
        #    due_date: current_date
        #  )

         # current_date =  current_date + 15.days
        #end
      end

      ::Loans::UpdateMaturityDate.new(
        loan: @loan
      ).execute!

      @loan
    end
  end
end
