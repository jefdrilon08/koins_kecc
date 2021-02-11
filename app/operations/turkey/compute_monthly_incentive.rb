module Turkey
  class ComputeMonthlyIncentive
    attr_reader :branch, :year, :month, :as_of, :incentive_table, :start_date, :end_date

    def initialize(branch:, year: nil, month: nil)
      @branch = branch
      @year   = year || Date.today.year
      @month  = month || Date.today.month
      @as_of  = Date.new(@year, @month, -1)

      @start_date = Date.new(@year, @month, 1)
      @end_date   = @as_of

      @incentive_table          = Settings.incentive_table
      @active_loaner_threshold  = Settings.active_loaner_threshold || 250
    end

    def execute!
      month_prev = as_of - 1.month
      as_of_prev = Date.new(month_prev.year, month_prev.month, -1)

      repayment_rate_prev   = find_data_stores :repayment_rates,          as_of_prev, :meta
      repayment_rate        = find_data_stores :repayment_rates,          as_of,      :meta
      new_and_resigned      = find_data_stores :monthly_new_and_resigned, as_of,      :meta
      new_and_resigned_prev = find_data_stores :monthly_new_and_resigned, as_of_prev, :meta
      member_counts         = find_data_stores :member_counts,            as_of,      :data
      member_counts_prev    = find_data_stores :member_counts,            as_of_prev, :data

      repayment_rate_records      = repayment_rate.data.fetch("records")
      prev_repayment_rate_records = repayment_rate_prev.data.fetch("records")

      officers = repayment_rate_records.pluck("officer").uniq

      records = officers.map do |officer|
        officer_id            = officer.fetch("id")

        resigned_members      = by_officer      officer_id, new_and_resigned,      "resigned_members"
        resigned_members_prev = by_officer      officer_id, new_and_resigned_prev, "resigned_members"
        new_members           = by_officer      officer_id, new_and_resigned,      "new_members"
        new_members_prev      = by_officer      officer_id, new_and_resigned_prev, "new_members"
        loaners               = by_count_member officer_id, member_counts,         "loaners"
        loaners_prev          = by_count_member officer_id, member_counts_prev,    "loaners"
        pure_savers           = by_count_member officer_id, member_counts,         "pure_savers"
        pure_savers_prev      = by_count_member officer_id, member_counts_prev,    "pure_savers"
        active_members        = by_count_member officer_id, member_counts,         "active_members"
        active_members_prev   = by_count_member officer_id, member_counts_prev,    "active_members"

        user              = User.find(officer_id)
        is_regular        = user.is_regular
        incentivized_date = user.incentivized_date

        loans                 = repayment_rate_records.select { |r| r["officer"]["id"] == officer["id"] }
        prev_loans            = prev_repayment_rate_records.select{ |r| r["officer"]["id"] == officer["id"] }

        loan_disbursements    = loans.select{ |o|
                                    if o.fetch("date_released").present? and o.fetch("date_released") != "N/A"
                                      date_released = o.fetch("date_released").try(:to_date)
                                      date_released.month == month and date_released.year == year
                                    else
                                      false
                                    end
                                  }.map do |l|
                                  {
                                    id:            l.dig("id"),
                                    principal:     l.dig("principal"),
                                    interest:      l.dig("interest"),
                                    date_released: l.dig("date_released"),
                                    pn_number:     l.dig("pn_number"),
                                    member: {
                                      id:          l.dig("member", "id"),
                                      first_name:  l.dig("member", "first_name"),
                                      middle_name: l.dig("member", "middle_name"),
                                      last_name:   l.dig("member", "last_name"),
                                    },
                                  }
                                end

        #amount_disbursed      = loans.pluck("principal").map(&:to_f).sum
        amount_disbursed  = loan_disbursements.inject(0){ |sum, hash| sum + hash[:principal].to_f }

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
        loan_p = loans.inject({}) do |hash, loan|
          loan_attrs.each { |attr| hash[attr] = hash[attr].to_f + loan[attr.to_s].to_f }
          hash
        end

        loan_prev = prev_loans.inject({}) do |hash, loan|
          loan_attrs.each { |attr| hash[attr] = hash[attr].to_f + loan[attr.to_s].to_f }
          hash
        end

        # RR = (Paid Due - Balance) / Paid Due
        principal_rr = (loan_p.fetch(:principal_paid_due) - loan_p.fetch(:principal_balance)) / loan_p.fetch(:principal_paid_due)
        interest_rr  = (loan_p.fetch(:interest_paid_due)  - loan_p.fetch(:interest_balance))  / loan_p.fetch(:interest_paid_due)
        total_rr     = (loan_p.fetch(:total_paid_due)     - loan_p.fetch(:total_balance))     / loan_p.fetch(:total_paid_due)

        prev_principal_rr = (loan_prev.fetch(:principal_paid_due) - loan_prev.fetch(:principal_balance)) / loan_prev.fetch(:principal_paid_due)
        prev_interest_rr  = (loan_prev.fetch(:interest_paid_due)  - loan_prev.fetch(:interest_balance))  / loan_prev.fetch(:interest_paid_due)
        prev_total_rr     = (loan_prev.fetch(:total_paid_due)     - loan_prev.fetch(:total_balance))     / loan_prev.fetch(:total_paid_due)

        # Par amount: overall * balance
        par_amount = loan_p.fetch(:principal_balance), # ???
        par        = loan_p.fetch(:principal_balance) / loan_p.fetch(:principal),

        prev_par_amount = loan_prev.fetch(:principal_balance),
        prev_par        = loan_prev.fetch(:principal_balance) / loan_prev.fetch(:principal),

        principal_past_due = loan_p.fetch(:principal_balance), # ???
        interest_past_due  = loan_p.fetch(:interest_balance), # ???
        total_past_due     = principal_past_due + interest_past_due,

        principal_portfolio = loan_p.fetch(:principal) - loan_p.fetch(:principal_paid_due)
        interest_portfolio  = loan_p.fetch(:interest) - loan_p.fetch(:interest_paid_due)
        total_portfolio     = principal_portfolio + interest_portfolio

        incentive = 0.00
        incentive_settings  = incentive_table.select{ |o| principal_rr >= o.min_rr and principal_rr <= o.max_rr }.first

        if incentive_settings.present?
          portfolio_settings  = incentive_settings.portfolio_table.select{ |p|
                                  principal_portfolio >= p.min and principal_portfolio <= p.max
                                }.first

          if portfolio_settings.present?
            incentive = portfolio_settings.amount
          end
        end

        drop_out_demerits = ((Settings.drop_out_demerits_per_member || 0.00) * resigned_members.size)
        total_demerits    = drop_out_demerits
        net_incentive     = incentive - total_demerits

        if net_incentive < 0.00
          net_incentive = 0.00
        end

        status  = (is_regular and incentivized_date.present? and incentivized_date <= as_of) ? "Regular" : "Trainee / Probation"

        if status != "Regular"
          net_incentive = 0.00
        end

        if loaners.size < @active_loaner_threshold
          net_incentive = 0.00
        end

        {
          status:                         status,
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
          loan_disbursements:              loan_disbursements,
          count_loan_disbursements:        loan_disbursements.size,
          amount_disbursed:                amount_disbursed,

          principal_rr:                    [principal_rr, 1].min, # Max is 100%
          interest_rr:                     [interest_rr, 1].min,
          total_rr:                        [total_rr, 1].min,

          prev_principal_rr:                [prev_principal_rr, 1].min, # Max is 100%
          prev_interest_rr:                 [prev_interest_rr, 1].min,
          prev_total_rr:                    [prev_total_rr, 1].min,

          par_amount:                      par_amount,
          par:                             par,

          prev_par_amount:                  prev_par_amount,
          prev_par:                         prev_par,

          principal_past_due:              principal_past_due,
          interest_past_due:               interest_past_due,
          total_past_due:                  total_past_due,

          principal_portfolio:             principal_portfolio,
          interest_portfolio:              interest_portfolio,
          total_portfolio:                 total_portfolio,

          incentive:                      incentive,
          verbal_warning_demerits:        0.00,
          written_warning_demerits:       0.00,
          drop_out_demerits:              drop_out_demerits,
          total_demerits:                 total_demerits,
          net_incentive:                  net_incentive
        }.merge(loan_p)
      end

      total_incentives      = records.inject(0){ |sum, hash| sum + hash[:net_incentive].to_f.round(2) }
      total_loans_disbursed = records.inject(0) { |sum, hash| sum + hash[:amount_disbursed].to_f.round(2) }
      total_active_loaners  = records.inject(0) { |sum, hash| sum + hash[:count_loaners].to_i }
      total_regular         = User.where(id: officers.pluck("id")).where("is_regular = ? AND incentivized_date <= ?", true, as_of).count
      average_incentive     = (total_incentives / total_regular).round(2)
      som_incentive         = (average_incentive * 0.75).round(2)

      {
        year:  year,
        month: month,
        as_of: as_of,
        officers: officers,
        branch: { id: branch.id, name: branch.name },
        records: records,
        total_incentives: total_incentives,
        total_regular: total_regular,
        som_incentive: som_incentive,
        average_incentive: average_incentive,
        total_loans_disbursed: total_loans_disbursed,
        total_active_loaners: total_active_loaners,
        start_date: start_date,
        end_date: end_date
      }
    end

    private

    def find_data_stores(scope, date, meta_or_data)
      ds = if meta_or_data == :meta
             DataStore.send(scope)
               .where("meta->>'branch_id' = ? AND CAST(meta->>'as_of' AS DATE) <= ?", branch.id, date)
               .order(Arel.sql("CAST(meta->>'as_of' AS DATE) ASC"))
               .last
           else
             DataStore.send(scope)
               .where("data->'branch'->>'id' = ? AND CAST(data->>'as_of' AS DATE) <= ?", branch.id, date)
               .order(Arel.sql("CAST(data->>'as_of' AS DATE) ASC"))
               .last
           end

      ds_date = ds.try!(:meta).dig("as_of").try!(:to_date)

      return ds if ds_date.year == date.year && ds_date.month == date.month

      raise "No report found (#{scope}) as_of: #{as_of}"
    end

    def by_officer(officer_id, records, key)
      records.data.fetch(key).select { |m| m.dig("officer", "id") == officer_id }
    end

    def by_count_member(officer_id, records, key)
      records.data.dig("counts", key, "members").select { |m| m.dig("officer", "id") == officer_id }
    end
  end
end
