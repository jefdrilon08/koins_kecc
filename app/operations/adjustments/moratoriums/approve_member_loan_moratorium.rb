module Adjustments
  module Moratoriums
    class ApproveMemberLoanMoratorium
      def initialize(config:)
        @config = config

        @member_loan_moratorium = @config[:member_loan_moratorium]
        @user                   = @config[:user]

        @loan             = @member_loan_moratorium.loan
        @date_initialized = @member_loan_moratorium.date_initialized
        @number_of_days   = @member_loan_moratorium.number_of_days
      end

      def execute!
        amortization_schedule_entries = AmortizationScheduleEntry.unpaid.where(
                                          "loan_id = ? AND due_date >= ?",
                                          @loan.id,
                                          @date_initialized
                                        ).order("due_date ASC")

        loan_term = @loan.term

        if amortization_schedule_entries.any?
          current_date  = amortization_schedule_entries.first.due_date
          iter          = 1

          amortization_schedule_entries.each do |o|
            if iter == 1
              o.update!(due_date: current_date + @number_of_days.days)
            else
              if loan_term == "weekly"
                o.update!(due_date: current_date + 7.days)
              elsif loan_term == "semi-monthly"
                o.update!(due_date: current_date + 15.days)
              elsif loan_term == "monthly"
                o.update!(due_date: current_date + 30.days)
              else
                raise "something went wrong for term: #{loan_term}"
              end
            end

            current_date = o.due_date
            iter = iter + 1
          end
        end

        @member_loan_moratorium.update!(
          status: "done"
        )
      end
    end
  end
end
