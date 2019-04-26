module Reports
  class GenerateLoanRepaymentReport
    def initialize(config:)
      @config = config
      @as_of  = @config[:as_of].try(:to_date) || Date.today
      @loan   = @config[:loan]

      @payments = AccountTransaction.approved_loan_payments.where(
                    "transacted_at <= ? AND subsidiary_id = ? AND subsidiary_type = ?",
                    @as_of,
                    @loan.id,
                    "Loan"
                  ).order("transacted_at ASC")

      @amorts = AmortizationScheduleEntry.where(
                  "due_date < ? AND loan_id = ?",
                  @as_of,
                  @loan.id
                ).order("due_date ASC")

      date_released = @loan.date_released

      if date_released.present?
        date_released = date_released.strftime("%b %d, %Y")
      else
        date_released = "N/A"
      end

      @data = {
        id: @loan.id,
        pn_number: @loan.pn_number,
        date_released: date_released,
        maturity_date: @loan.maturity_date,
        loan_product: {
          id: @loan.loan_product.id,
          name: @loan.loan_product.name
        },
        member: {
          id: @loan.member.id,
          first_name: @loan.member.first_name,
          last_name: @loan.member.last_name,
          middle_name: @loan.member.middle_name,
          identification_number: @loan.member.identification_number
        },
        branch: {
          id: @loan.branch.id,
          name: @loan.branch.name
        },
        center: {
          id: @loan.center.id,
          name: @loan.center.name
        },
        officer: {
          id: @loan.center.user.id,
          first_name: @loan.center.user.first_name,
          last_name: @loan.center.user.last_name
        },
        principal:                  0.00,
        interest:                   0.00,
        total:                      0.00,
        principal_due:              0.00,
        interest_due:               0.00,
        total_due:                  0.00,
        principal_paid:             0.00,
        interest_paid:              0.00,
        principal_paid_due:         0.00,
        interest_paid_due:          0.00,
        total_paid_due:             0.00,
        total_paid:                 0.00,
        principal_balance:          0.00,
        interest_balance:           0.00,
        total_balance:              0.00,
        overall_principal_balance:  0.00,
        overall_interest_balance:   0.00,
        overall_balance:            0.00,
        principal_rr:               0,
        interest_rr:                0,
        total_rr:                   0,
        par:                        0,
        num_days_par:               0
      }
    end

    def execute!
      principal_due = @amorts.sum(:principal).round(2)
      interest_due  = @amorts.sum(:interest).round(2)
      total_due     = (principal_due + interest_due).round(2)

      principal = @loan.principal
      interest  = @loan.interest
      total     = (principal + interest).round(2)

      principal_paid  = @payments.sum("CAST(data->>'total_principal_paid' AS decimal)").round(2)
      interest_paid   = @payments.sum("CAST(data->>'total_interest_paid' AS decimal)").round(2)
      total_paid      = (principal_paid + interest_paid).round(2)

      principal_balance = (principal_due - principal_paid).round(2)

      if principal_balance < 0
        principal_balance = 0.00
      end

      interest_balance  = (interest_due - interest_paid).round(2)

      if interest_balance < 0
        interest_balance = 0.00
      end

      total_balance     = (principal_balance + interest_balance).round(2)

      # Compute paid due
      if principal_paid >= principal_due
        principal_paid_due  = principal_due
      else
        principal_paid_due  = principal_paid
      end

      if interest_paid >= interest_due
        interest_paid_due  = interest_due
      else
        interest_paid_due  = interest_paid
      end

      total_paid_due  = (principal_paid_due + interest_paid_due).round(2)

      overall_principal_balance = (principal - principal_paid).round(2)

      if overall_principal_balance < 0
        overall_principal_balance = 0.00
      end

      overall_interest_balance  = (interest - interest_paid).round(2)

      if overall_interest_balance < 0
        interest_balance  = 0.00
      end

      overall_balance = (overall_principal_balance + overall_interest_balance).round(2)

      # Repayment rate
      principal_rr  = (principal_paid_due / principal_due).round(4)
      interest_rr   = (interest_paid_due / interest_due).round(4)
      total_rr      = (total_paid_due / total_due).round(4) 

      # Repayment rate
      if principal_paid_due > 0
      else
        principal_rr  = 0.00;
      end

      if interest_paid_due > 0
      else
        interest_rr  = 0.00;
      end

      if total_paid_due > 0
      else
        total_rr  = 0.00;
      end

      # Clear repayment rates
      if principal_rr > 1
        principal_rr = 1
      end

      if principal_rr >= 1 and principal_paid < principal_due
        principal_rr = 0.99
      end

      if interest_rr > 1
        interest_rr = 1
      end

      if interest_rr >= 1 and interest_paid < interest_due
        interest_rr = 0.99
      end

      if total_rr > 1
        total_rr = 1
      end

      if total_rr >= 1 and total_paid < total_due
        total_rr = 0.99
      end

      # PAR
      par = (principal_balance / principal).round(2)

      last_payment  = @payments.last

      num_days_par = 0

      if @amorts.size > 0
        num_days_par  = (@as_of - @amorts.first.due_date).days

        if last_payment.present?
          if last_payment.data.with_indifferent_access[:amort_entries].try(:last).blank?
            raise "No data->amort_entries for account transaction #{last_payment.id}"
          end

          last_paid_date      = last_payment.data.with_indifferent_access[:amort_entries].last[:due_date].to_date
          latest_unpaid_amort = @amorts.where("due_date >= ?", last_paid_date).order("due_date ASC").first

          if latest_unpaid_amort.present? and par > 0
            num_days_par  = (@as_of - latest_unpaid_amort.due_date).to_i
          else
            num_days_par  = 0
          end
        end
      end

      @data[:principal]         = principal
      @data[:interest]          = interest
      @data[:total]             = total
      @data[:principal_due]     = principal_due
      @data[:interest_due]      = interest_due
      @data[:total_due]         = total_due
      @data[:principal_paid]    = principal_paid
      @data[:interest_paid]     = interest_paid
      @data[:total_paid]        = total_paid
      @data[:principal_balance] = principal_balance
      @data[:interest_balance]  = interest_balance
      @data[:total_balance]     = total_balance
      @data[:overall_principal_balance] = overall_principal_balance
      @data[:overall_interest_balance]  = overall_interest_balance
      @data[:overall_balance]           = overall_balance
      @data[:principal_paid_due]        = principal_paid_due
      @data[:interest_paid_due]         = interest_paid_due
      @data[:total_paid_due]            = total_paid_due
      @data[:principal_rr]      = principal_rr
      @data[:interest_rr]       = interest_rr
      @data[:total_rr]          = total_rr
      @data[:par]               = par
      @data[:num_days_par]      = num_days_par

      @data
    end
  end
end
