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
      @monthly_interest_rate        = (@annual_interest_rate / 12.0)

      # Check if dormant
      if @dormant_annual_interest_rate.present?
        loan_ids  = Loan.active_or_paid.where(
                      member_id: @member_account.member.id
                    ).pluck(:id)

        latest_payment  = AccountTransaction.approved_loan_payments.where(
                            subsidiary_id: loan_ids
                          ).order("transacted_at ASC").last

        threshold_date  = @closing_date - @dormant_threshold_months.to_i.months

        if latest_payment.present? && latest_payment.transacted_at < threshold_date
          @annual_interest_rate   = @dormant_annual_interest_rate
          @monthly_interest_rate  = (@annual_interest_rate / 12.0)
        end
      end

      @data = {
        member_account: {
          id: @member_account.id,
          account_type: @member_account.account_type,
          account_subtype: @member_account.account_subtype
        },
        member: {
          id: @member_account.id,
          first_name: @member_account.member.first_name,
          last_name: @member_account.member.last_name
        },
        interest: 0.00,
        records: [],
        transactions: []
      }
    end

    def execute!
      @latest_interest_transaction  = AccountTransaction.interest.where(
                                        subsidiary_id: @member_account.id
                                      ).order("transacted_at ASC").last

      if @latest_interest_transaction.blank?
        @latest_interest_transaction  = AccountTransaction.savings_deposits.where(subsidiary_id: @member_account.id).first
      end

      records = []
      if @latest_interest_transaction.present?
        @account_transactions = AccountTransaction.savings_deposits.where(
                                  "subsidiary_id = ? AND transacted_at > ? AND transacted_at <= ?",
                                  @member_account.id,
                                  @latest_interest_transaction.transacted_at,
                                  @closing_date
                                ).order("transacted_at ASC")

        @transaction_dates  = @account_transactions.pluck(:transacted_at).uniq

        # TODO: O(n^2) --> optimize this
        @transaction_dates.each_with_index do |d, d_index|
          r = {
            date: d.to_date,
            beginning_balance: 0.00,
            deposits: 0.00,
            withdrawals: 0.00,
            interest_per_month: 0.00,
            interest_earned_on_deposits: 0.00,
            ending_balance: 0.00,
            num_days_before_next_transaction: 0
          }

          @account_transactions.each_with_index do |t, i|
            data  = t.data.with_indifferent_access

            if t.transacted_at.to_date == d.to_date
              if i == 0
                r[:beginning_balance] = data[:beginning_balance]
              end

              if t.transaction_type == "deposit"
                r[:deposits] += t.amount.to_f.round(2)
              elsif t.transaction_type == "withdraw"
                r[:withdrawals] += t.amount.to_f.round(2)
              end
            end
          end

          r[:ending_balance]                    = (r[:ending_balance] + r[:deposits] - r[:withdrawals]).to_f.round(2)
          r[:interest_per_month]                = (@monthly_interest_rate * r[:ending_balance]).to_f.round(2)
          r[:num_days_before_next_transaction]  = 0

          if d_index < (@transaction_dates.size - 1)
            r[:num_days_before_next_transaction]  = (@transaction_dates[d_index + 1] - d).to_i
          end

          r[:interest_earned_on_deposits]       = ((r[:interest_per_month] * r[:num_days_before_next_transaction]) / 30).round(2)

          @data[:interest] += r[:interest_earned_on_deposits]

          records << r
        end

        @data[:records] = records

        @data[:account_transactions]  = @account_transactions.map{ |t|
                                          {
                                            id: t.id,
                                            subsidiary_id: t.subsidiary_id,
                                            subsidiary_type: t.subsidiary_type,
                                            amount: t.amount,
                                            transaction_type: t.transaction_type,
                                            transacted_at: t.transacted_at,
                                            status: t.status,
                                            data: t.data
                                          }
                                        }

      end

      @data
    end
  end
end
