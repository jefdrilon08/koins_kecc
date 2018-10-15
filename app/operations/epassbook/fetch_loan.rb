module Epassbook
  class FetchLoan
    def initialize(member:, loan:)
      @member = member
      @loan   = loan

      @amortization_schedule_entries  = @loan.amortization_schedule_entries.order("due_date ASC")

      @data = {
        member: {
          first_name: @member.first_name,
          middle_name: @member.middle_name,
          last_name: @member.last_name
        },
        loan: {
          id: @loan.id,
          pn_number: @loan.pn_number,
          principal: @loan.principal,
          interest: @loan.interest,
          principal_paid: @loan.principal_paid,
          interest_paid: @loan.interest_paid,
          amortization: [],
          payments: []
        }
      }
    end

    def execute!
      @amortization_schedule_entries.each do |o|
        @data[:loan][:amortization] << {
          id: o.id,
          due_date: o.due_date.strftime("%B %d, %Y"),
          paid: o.total_paid,
          balance: o.total_balance,
          amount_due: o.amount_due
        }
      end

      @data
    end
  end
end
