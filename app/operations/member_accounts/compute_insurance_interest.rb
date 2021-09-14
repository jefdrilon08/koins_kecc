module MemberAccounts
  class ComputeInsuranceInterest
    def initialize(member_account:, closing_date:, account_settings:)
      @member_account   = member_account
      @closing_date     = closing_date
      @account_settings = account_settings

      @annual_interest_rate         = @account_settings.annual_interest_rate
      @monthly_interest_rate        = (@annual_interest_rate / 12.0)
    end

    def execute!
      end_of_last_month = @closing_date.last_month.end_of_month
      tx_before_range   = txs_by_range(to: end_of_last_month).last
      txs_within_range  = txs_by_range(from: end_of_last_month, to: @closing_date)
      tx_datetimes      = [end_of_last_month] + txs_within_range.map(&:transacted_at).uniq
      total_interest    = 0.0

      records = tx_datetimes.map.with_index do |datetime, i|
        txs = if tx_before_range.present? && datetime == end_of_last_month
                [tx_before_range]
              else
                txs_within_range.select { |tx| tx.transacted_at == datetime }.sort_by(&:created_at)
              end

        deposits            = txs.select { |tx| tx.transaction_type == "deposit" }.sum(&:amount).to_f
        withdrawals         = txs.select { |tx| tx.transaction_type == "withdraw" }.sum(&:amount).to_f
        beginning_balance   = txs.empty? ? 0.0 : txs.first.data.fetch("beginning_balance").to_f
        ending_balance      = txs.empty? ? 0.0 : txs.last.data.fetch("ending_balance").to_f
        next_tx_date        = datetime != tx_datetimes.last ? tx_datetimes[i + 1].to_date : @closing_date
        days_before_next_tx = (next_tx_date - datetime.to_date).to_i
        interest_per_month  = @monthly_interest_rate * ending_balance
        interest_earned     = days_before_next_tx * interest_per_month / 30

        total_interest += interest_earned

        {
          date:                             datetime.to_date,
          deposits:                         deposits.round(2),
          withdrawals:                      withdrawals.round(2),
          beginning_balance:                beginning_balance.round(2),
          ending_balance:                   ending_balance.round(2),
          net_amount:                       0.0,
          num_days_before_next_transaction: days_before_next_tx,
          interest_per_month:               interest_per_month.round(2),
          interest_earned_on_deposits:      interest_earned.round(2),
        }
      end

      {
        closing_date:          @closing_date,
        monthly_interest_rate: @monthly_interest_rate,
        annual_interest_rate:  @annual_interest_rate,
        member_account: {
          id:              @member_account.id,
          account_type:    @member_account.account_type,
          account_subtype: @member_account.account_subtype
        },
        member: {
          id:         @member_account.try!(:member).try!(:id),
          first_name: @member_account.try!(:member).try!(:first_name),
          last_name:  @member_account.try!(:member).try!(:last_name),
        },
        interest: total_interest.round(2),
        starting_transaction: starting_transaction(tx_before_range, end_of_last_month),
        records: records,
      }
    end

    private

    def starting_transaction(tx, transacted_at)
      {
        id:             (tx ? tx.id : ""),
        ending_balance: (tx ? tx.data["ending_balance"].to_f.round(2) : 0.0),
        transacted_at:  transacted_at,
      }
    end

    def txs_by_range(from: nil, to:)
      AccountTransaction.find_by_sql(<<-SQL)
        SELECT id, transaction_type, amount, data, transacted_at, created_at
        FROM account_transactions
        WHERE transaction_type
          IN ('deposit', 'withdraw')
          AND subsidiary_id = '#{@member_account.id}'
          #{"AND transacted_at > '#{from}'" if from}
          AND DATE(transacted_at) <= '#{to}'
        ORDER BY transacted_at ASC, updated_at ASC, created_at ASC
      SQL
    end
  end
end
