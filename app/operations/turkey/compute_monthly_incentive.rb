module Turkey
  class ComputeMonthlyIncentive
    attr_reader :branch, :year, :month, :as_of

    def initialize(branch:, year: nil, month: nil)
      @branch = branch
      @year   = year || Date.today.year
      @month  = month || Date.today.month
      @as_of  = Date.new(@year, @month, -1)

      month_prev = as_of - 1.month
      as_of_prev = Date.new(month_prev.year, month_prev.month, -1)

      @repayment_rate        = find_data_stores :repayment_rates,          as_of,      :meta
      @new_and_resigned      = find_data_stores :monthly_new_and_resigned, as_of,      :meta
      @new_and_resigned_prev = find_data_stores :monthly_new_and_resigned, as_of_prev, :meta
      @member_counts         = find_data_stores :member_counts,            as_of,      :data
      @member_counts_prev    = find_data_stores :member_counts,            as_of_prev, :data
    end

    def execute!
      repayment_rate_records = @repayment_rate.data.fetch("records")
      officers = repayment_rate_records.pluck("officer").uniq

      records = officers.map do |officer|
        officer_id            = officer.fetch(:id)

        resigned_members      = by_officer      officer_id, @new_and_resigned,      "resigned_members"
        resigned_members_prev = by_officer      officer_id, @new_and_resigned_prev, "resigned_members"
        new_members           = by_officer      officer_id, @new_and_resigned,      "new_members"
        new_members_prev      = by_officer      officer_id, @new_and_resigned_prev, "new_members"
        loaners               = by_count_member officer_id, @member_counts,         "loaners"
        loaners_prev          = by_count_member officer_id, @member_counts_prev,    "loaners"
        pure_savers           = by_count_member officer_id, @member_counts,         "pure_savers"
        pure_savers_prev      = by_count_member officer_id, @member_counts_prev,    "pure_savers"
        active_members        = by_count_member officer_id, @member_counts,         "active_members"
        active_members_prev   = by_count_member officer_id, @member_counts_prev,    "active_members"

        loans                 = repayment_rate_records.select { |r| r["officer"]["id"] == officer["id"] }
        loan_disbursements    = Loan
                                .where(id: loans.pluck("id").uniq)
                                .where("extract(year FROM date_released) = ? AND extract(month FROM date_released) = ?", year, month)
        amount_disbursed      = loan_disbursements.sum(:principal)
        loan_disbursements_h  = loan_disbursements.map do |l|
                                  {
                                    id:            l.id,
                                    principal:     l.principal,
                                    interest:      l.interest,
                                    date_released: l.date_released,
                                    pn_number:     l.pn_number,
                                    member:        {
                                                     id:          l.member.id,
                                                     first_name:  l.member.first_name,
                                                     middle_name: l.member.middle_name,
                                                     last_name:   l.member.last_name,
                                                   },
                                  }
                                end

        loan_attrs = %i[
          interest
          interest_balance
          interest_due
          interest_paid
          interest_paid_due
          principal
          principal_balance
          principal_due
          principal_paid
          principal_paid_due
          overall_balance
          overall_interest_balance
          overall_principal_balance
          total
          total_balance
          total_due
          total_paid
          total_paid_due
        ]
        # loan particulars
        loan_p = loans.inject({}) do |l|
          loan_attrs.each { |hash, attr| hash[attr] = hash[attr].to_f + l.fetch(attr.to_s).to_f }
        end

        # RR = (Paid Due - Balance) / Paid Due
        principal_rr = (loan_p.fetch(:principal_paid_due) - loan_p.fetch(:principal_balance)) / loan_p.fetch(:principal_paid_due)
        interest_rr  = (loan_p.fetch(:interest_paid_due)  - loan_p.fetch(:interest_balance))  / loan_p.fetch(:interest_paid_due)
        total_rr     = (loan_p.fetch(:total_paid_due)     - loan_p.fetch(:total_balance))     / loan_p.fetch(:total_paid_due)

        # Par amount: overall * balance
        par_amount = loan_p.fetch(:principal_balance), # ???
        par        = loan_p.fetch(:principal_balance) / loan_p.fetch(:principal),

        principal_past_due = loan_p.fetch(:principal_balance), # ???
        interest_past_due  = loan_p.fetch(:interest_balance), # ???
        total_past_due     = principal_past_due + interest_past_due,

        principal_portfolio = loan_p.fetch(:principal) - loan_p.fetch(:principal_paid_due)
        interest_portfolio  = loan_p.fetch(:interest) - loan_p.fetch(:interest_paid_due)
        total_portfolio     = principal_portfolio + interest_portfolio

        {
          resigned_members:                resigned_members,
          count_resigned_members:          resigned_members.size,
          previous_resigned_members:       resigned_members_prev,
          previous_count_resigned_members: resigned_members_prev.size,

          new_members:                     new_members,
          count_new_members:               new_members.size,
          previous_new_members:            new_members_prev,
          previous_count_new_members:      new_members_prev.size,

          loaners:                         loaners,
          count_loaners:                   loaners.size,
          previous_loaners:                loaners_prev,
          previous_count_loaners:          loaners_prev.size,

          pure_savers:                     pure_savers,
          count_pure_savers:               pure_savers.size,
          previous_pure_savers:            pure_savers_prev,
          previous_count_pure_savers:      pure_savers_prev.size,

          active_members:                  active_members,
          count_active_members:            active_members.size,
          previous_active_members:         active_members_prev,
          previous_count_active_members:   active_members_prev.size,
          previous_member_count:           (loaners_prev.size + pure_savers_prev.size + active_members_prev.size),

          loans:                           loans,
          loan_disbursements:              loan_disbursements_h,
          count_loan_disbursements:        loan_disbursements_h.size,
          amount_disbursed:                amount_disbursed,

          principal_rr:                    [principal_rr, 1].min, # Max is 100%
          interest_rr:                     [interest_rr, 1].min,
          total_rr:                        [total_rr, 1].min,

          par_amount:                      par_amount,
          par:                             par,

          principal_past_due:              principal_past_due,
          interest_past_due:               interest_past_due,
          total_past_due:                  total_past_due,

          principal_portfolio:             principal_portfolio,
          interest_portfolio:              interest_portfolio,
          total_portfolio:                 total_portfolio,
        }.merge(loan_particulars)
      end

      {
        year:  year,
        month: month,
        as_of: as_of,
        officers: officers,
        branch: { id: branch.id, name: branch.name },
        records: records,
      }
    end

    private

    def find_data_stores(scope, date, meta_or_data)
      ds = if meta_or_data == :meta
             DataStore.send(scope)
               .where("meta->>'branch_id' = ? AND CAST(meta->>'as_of' AS DATE) <= ?", branch.id, date)
               .order("CAST(meta->>'as_of' AS DATE) ASC")
               .last
           else
             DataStore.send(scope)
               .where("data->'branch'->>'id' = ? AND CAST(data->>'as_of' AS DATE) <= ?", branch.id, date)
               .order("CAST(data->>'as_of' AS DATE) ASC")
               .last
           end

      ds_date = ds.try!(:meta).dig("as_of").try!(:to_date)

      return ds if ds_date.year == date.year && ds_date.month == date.month

      raise "no report found. as_of: #{as_of}"
    end

    def by_officer(officer_id, records, key)
      records.data.fetch(key).select { |m| m.dig("officer", "id") == officer_id }
    end

    def by_count_member(officer_id, records, key)
      records.data.dig("counts", key, "members").select { |m| m.dig("officer", "id") == officer_id }
    end
  end
end
