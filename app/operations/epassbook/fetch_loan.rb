module Epassbook
  class FetchLoan
    include ActionView::Helpers::NumberHelper

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
          loan_product: @loan.loan_product.name,
          principal: number_to_currency(@loan.principal, unit: ""),
          interest: number_to_currency(@loan.interest, unit: ""),
          principal_paid: number_to_currency(@loan.principal_paid, unit: ""),
          interest_paid: number_to_currency(@loan.interest_paid, unit: ""),
          date_released: @loan.date_released.present? ? @loan.date_released.strftime('%D') : N/A,
          amortization: [], 
          payments: []
        }
      }

      @running_balance = @loan.principal + @loan.interest
    end

    def execute!
      @amortization_schedule_entries.each do |o|
        @running_balance -= o.total_paid
        paid_html = ""


        if o.data["is_paid"] == true
          paid_html = "<span class='badge badge-success'>paid</span>"
        end

        if o.is_paid == true
          paid = "paid"
        end

        @data[:loan][:amortization] << {
          id: o.id,
          due_date: o.due_date.strftime("%B %d, %Y"),
          paid: number_to_currency(o.total_paid, unit: ""),
          balance: number_to_currency(o.total_balance, unit: ""),
          amount_due: number_to_currency(o.amount_due, unit: ""),
          running_balance: number_to_currency(@running_balance, unit: ""),
          is_paid: paid,
          paid_html: paid_html
        }
      end

      @data
    end
  end
end
