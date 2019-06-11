module MemberAccounts
  class ComputeInterest
    def initialize(config:)
      @config = config

      @member_account   = @config[:member_account]
      @closing_date     = @config[:closing_date]
      @account_type     = @config[:account_type]
      @account_subtype  = @config[:account_subtype]
      @account_settings = @config[:account_settings]

      @dormant_threshold_months     = @account_settings.dormant_threshold_months
      @dormant_annual_interest_rate = @account_settings.dormant_annual_interest_rate || 0
      @annual_interest_rate         = @account_settings.annual_interest_rate
      @zero_interest_threshold      = @account_settings.zero_interest_threshold
      @monthly_interest_rate        = (@annual_interest_rate / 12.0)

      # Check if zero_interest_threshold is applicable
      @latest_transaction = AccountTransaction.savings.where(
                              "subsidiary_id = ? AND DATE(transacted_at) <= ?",
                              @member_account.id,
                              @closing_date
                            ).where.not(
                              "data->>'is_interest' = ?",
                              'true'
                            ).order("transacted_at ASC, created_at ASC").last

      if @latest_transaction.present? and @zero_interest_threshold.present?
        threshold_date  = @closing_date - @zero_interest_threshold.to_i.months

        #raise "#{@latest_transaction.transacted_at.to_date < threshold_date} Latest Transaction: #{@latest_transaction.transacted_at.to_date} Threshold Date: #{threshold_date}"

        if @latest_transaction.transacted_at.to_date < threshold_date
          @annual_interest_rate   = 0
          @monthly_interest_rate  = 0
        else
          # Check if dormant
          is_dormant  = ::MemberAccounts::IsDormant.new(
                          config: {
                            member_account: @member_account,
                            closing_date: @closing_date,
                            account_settings: @account_settings
                          }
                        ).execute!

          if is_dormant
            @annual_interest_rate   = @dormant_annual_interest_rate
            @monthly_interest_rate  = (@annual_interest_rate / 12.0)
          end
        end
      else
        # Check if dormant
        is_dormant  = ::MemberAccounts::IsDormant.new(
                        config: {
                          member_account: @member_account,
                          closing_date: @closing_date,
                          account_settings: @account_settings
                        }
                      ).execute!

        if is_dormant
          @annual_interest_rate   = @dormant_annual_interest_rate
          @monthly_interest_rate  = (@annual_interest_rate / 12.0)
        end
      end

#      if @dormant_annual_interest_rate.present?
#        loan_ids  = Loan.active_or_paid.where(
#                      member_id: @member_account.member.id
#                    ).pluck(:id)
#
#        latest_payment  = AccountTransaction.approved_loan_payments.where(
#                            subsidiary_id: loan_ids
#                          ).order("transacted_at ASC").last
#
#        threshold_date  = @closing_date - @dormant_threshold_months.to_i.months
#
#        # No latest transaction
#        if latest_payment.blank?
#          @annual_interest_rate   = @dormant_annual_interest_rate
#          @monthly_interest_rate  = (@annual_interest_rate / 12.0)
#        end
#
#        if latest_payment.present? && latest_payment.transacted_at < threshold_date
#          @annual_interest_rate   = @dormant_annual_interest_rate
#          @monthly_interest_rate  = (@annual_interest_rate / 12.0)
#        end
#      end


      @data = {
        closing_date: @closing_date,
        monthly_interest_rate: @monthly_interest_rate,
        annual_interest_rate: @annual_interest_rate,
        member_account: {
          id: @member_account.id,
          account_type: @member_account.account_type,
          account_subtype: @member_account.account_subtype
        },
        member: {
          id: @member_account.member.id,
          first_name: @member_account.member.first_name,
          last_name: @member_account.member.last_name
        },
        interest: 0.00,
        starting_transaction: {
          id: "",
          transacted_at: "",
          ending_balance: 0.00
        },
        records: []
      }
    end

    def execute!
      month_before                                  = @closing_date.last_month.end_of_month
      @data[:starting_transaction][:transacted_at]  = month_before

      @latest_transaction = AccountTransaction.savings.where(
                              "subsidiary_id = ? AND DATE(transacted_at) <= ?",
                              @member_account.id,
                              month_before
                            ).order("transacted_at ASC, created_at ASC").last

      if @latest_transaction.present?
        @data[:starting_transaction][:id]             = @latest_transaction.id
        @data[:starting_transaction][:ending_balance] = @latest_transaction.data.with_indifferent_access[:ending_balance].to_f
      end

      @account_transactions = AccountTransaction.savings.where(
                                "subsidiary_id = ? AND transacted_at > ? AND DATE(transacted_at) <= ?",
                                @member_account.id,
                                month_before,
                                @closing_date
                              ).order("transacted_at ASC, created_at ASC")

      # Storage of transaction records
      records = []

      # First transaction of record should be latest transaction
      r = {
        date: @data[:starting_transaction][:transacted_at].to_date,
        beginning_balance: 0.00,
        deposits: 0.00,
        withdrawals: 0.00,
        interest_per_month: 0.00,
        interest_earned_on_deposits: 0.00,
        ending_balance: 0.00,
        num_days_before_next_transaction: 0
      }

      if @latest_transaction.present?
        latest_transaction_data = @latest_transaction.data.with_indifferent_access

        r[:beginning_balance] = latest_transaction_data[:beginning_balance].to_f.round(2)
        r[:ending_balance]    = latest_transaction_data[:ending_balance].to_f.round(2)

        if @latest_transaction.transaction_type == "deposit"
          r[:deposits]    = @latest_transaction.amount
        elsif @latest_transaction.transaction_type == "withdraw"
          r[:withdrawals] = @latest_transaction.amount
        end
      end

      @transaction_dates  = @account_transactions.pluck(:transacted_at).uniq

      if @transaction_dates.size > 0
        r[:interest_per_month]                = (@monthly_interest_rate * r[:ending_balance]).to_f.round(2)
        r[:num_days_before_next_transaction]  = (@transaction_dates.first.to_date - r[:date].to_date).to_i
        r[:interest_earned_on_deposits]       = ((r[:interest_per_month] * r[:num_days_before_next_transaction]) / 30).round(2)

        @data[:interest] += r[:interest_earned_on_deposits]
      else
        r[:interest_per_month]                = (@monthly_interest_rate * r[:ending_balance]).to_f.round(2)
        r[:num_days_before_next_transaction]  = (@closing_date - r[:date].to_date).to_i
        r[:interest_earned_on_deposits]       = ((r[:interest_per_month] * r[:num_days_before_next_transaction]) / 30).round(2)

        @data[:interest] += r[:interest_earned_on_deposits]
      end

      # Load first transaction
      records << r

      # TODO: O(n^2) --> optimize this
      @transaction_dates.each_with_index do |d, d_index|
        r = {
          date: d.to_date,
          beginning_balance: 0.00,
          deposits: 0.00,
          withdrawals: 0.00,
          net_amount: 0.00,
          interest_per_month: 0.00,
          interest_earned_on_deposits: 0.00,
          ending_balance: 0.00,
          num_days_before_next_transaction: 0
        }

        current_date_transactions = @account_transactions.where("CAST(transacted_at AS DATE) = ?", d).order("transacted_at ASC, updated_at ASC")

        r[:beginning_balance] = current_date_transactions.first.data.with_indifferent_access[:beginning_balance].to_f.round(2)
        r[:deposits]          = current_date_transactions.where(transaction_type: "deposit").sum(:amount)
        r[:withdrawals]       = current_date_transactions.where(transaction_type: "withdraw").sum(:amount)
        r[:ending_balance]    = current_date_transactions.last.data.with_indifferent_access[:ending_balance].to_f.round(2)

        r[:interest_per_month]                = (@monthly_interest_rate * r[:ending_balance]).to_f.round(2)

        if d_index < (@transaction_dates.size - 1)
          r[:num_days_before_next_transaction]  = (@transaction_dates[d_index + 1].to_date - d.to_date).to_i
        elsif d_index == (@transaction_dates.size - 1)
          r[:num_days_before_next_transaction]  = (@closing_date - @transaction_dates[d_index].to_date).to_i
        end

        r[:interest_earned_on_deposits]       = ((r[:interest_per_month] * r[:num_days_before_next_transaction]) / 30).round(2)

        @data[:interest] += r[:interest_earned_on_deposits]

        records << r
      end

      @data[:records] = records

      @data
    end
  end
end
