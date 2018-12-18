module MemberAccounts
  class ComputeInterestAndTax
    def initialize(config:)
      @config = config

      @member_account = @config[:member_account]
      @closing_date   = @config[:closing_date]

      # Get settings
      @interest_member_accounts = Settings.interest_member_accounts
      @account_settings         = nil

      if @interest_member_accounts.blank?
        raise "No settings found: interest_member_accounts"
      else
        @interest_member_accounts.each do |o|
          if o.account_type == @member_account.account_type and o.account_subtype == @member_account.account_subtype
            @account_settings = o
          end
        end

        if @account_settings.blank?
          raise "No settings extracted for account_settings | account_type: #{@member_account.account_type} accout_subtype: #{@member_accout.account_subtyp@member_accout.account_subtypee}"
        end
      end

      @dormant_threshold_months     = @account_settings.dormant_threshold_months
      @dormant_annual_interest_rate = @account_settings.dormant_annual_interest_rate || 0
      @annual_interest_rate         = @account_settings.annual_interest_rate
      @monthly_interest_rate        = (@annual_interest_rate / 12.0)

      @annual_tax_rate  = @account_settings.annual_tax_rate
      @monthly_tax_rate = (@annual_tax_rate / 12.0)

      # Check if dormant
      if @dormant_annual_interest_rate.present?
        loan_ids  = Loan.active_or_paid.where(
                      member_id: @member_account.member.id
                    ).pluck(:id)

        latest_payment  = AccountTransaction.approved_loan_payments.where(
                            subsidiary_id: loan_ids
                          ).order("transacted_at ASC").last

        threshold_date  = @closing_date - @dormant_threshold_months.to_i.months

        if latest_payment.transacted_at < threshold_date
          @annual_interest_rate   = @dormant_annual_interest_rate
          @monthly_interest_rate  = (@annual_interest_rate / 12.0)
        end
      end

      @last_working_date  = ::Utils::GetLastWorkingDay.new(
                              some_date: (@closing_date - 1.month)
                            ).execute!

      # Fetch account transactions
      @account_transactions = AccountTransaction.approved.where(
                                "subsidiary_id = ? AND extract(month from transacted_at) = ? AND extract(year from transacted_at) = ?",
                                @member_account.id,
                                @closing_date.month,
                                @closing_date.year
                              ).order("transacted_at ASC, created_at ASC")

      @last_month_transactions  = AccountTransaction.approved.where(
                                    "subsidiary_id = ? AND extract(month from transacted_at) = ? AND extract(year from transacted_at) = ?",
                                    @member_account.id,
                                    @last_working_date.month,
                                    @last_working_date.year
                                  ).order("transacted_at ASC, created_at ASC")

      @latest_transaction = @last_month_transactions.last

      if @latest_transaction.blank?
        @latest_transaction = AccountTransaction.approved.where(
                                "subsidiary_id = ? AND transacted_at > ? AND transacted_at < ?",
                                @member_account.id,
                                @last_working_date,
                                @closing_date
                              ).order("transacted_at ASC, created_at ASC").last

        if @latest_transaction.present?
          @last_working_date  = @latest_transaction.transacted_at.to_date
        end
      end

      @ending_balance = 0.00

      if @latest_transaction.present?
        @ending_balance = @latest_transaction.data["ending_balance"].to_f.round(2)
      end

      # Number of days before next transaction
      @num_days_before_next_transaction = (@closing_date - @last_working_date).to_i

      if @account_transactions.size > 0
        @num_days_before_next_transaction = (@account_transactions.first.transacted_at.to_date - @last_working_date).to_i
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
        tax: 0.00,
        records: [],
        transactions: []
      }
    end

    def execute!
      if @ending_balance > 0
        records = []

        interest_per_month          = (@ending_balance * @monthly_interest_rate).to_f.round(3)
        interest_earned_on_deposits = ((interest_per_month * @num_days_before_next_transaction) / 30.0).to_f.round(3)
        withholding_tax_on_deposits = (interest_earned_on_deposits * @monthly_tax_rate).to_f.round(3)

        r = {
          transacted_at: @last_working_date,
          beginning_balance: 0.00,
          ending_balance: @ending_balance,
          deposits: 0.00,
          withdrawals: 0.00,
          num_days_before_next_transaction: @num_days_before_next_transaction,
          interest_per_month: interest_per_month,
          interest_earned_on_deposits: interest_earned_on_deposits,
          withholding_tax_on_deposits: withholding_tax_on_deposits
        }

        records << r

        transaction_dates = @account_transactions.pluck(:transacted_at)
        transaction_dates.each_with_index do |d, i|
          temp_transactions = @account_transactions.where(transacted_at: d).order("transacted_at ASC, created_at ASC")

          num_days_before_next_transaction  = (transaction_dates[i+1].to_date - d).to_i

          if i == transaction_dates.cout - 1
            num_days_before_next_transaction  = (@closing_date - transacted_at.to_date).to_i
          end

          beginning_balance   = temp_transactions.first.data["beginning_balance"].to_f.round(3)
          ending_balance      = temp_transactions.last.data["ending_balance"].to_f.round(3)

          interest_per_month          = (ending_balance * @monthly_interest_rate).to_f.round(3)
          interest_earned_on_deposits = ((interest_per_month * num_days_before_next_transaction) / 30.0).to_f.round(3)
          withholding_tax_on_deposits = (interest_earned_on_deposits * @monthly_tax_rate).to_f.round(3)
          r = {
            transacted_at: d,
            beginning_balance: beginning_balance,
            ending_balance: ending_balance,
            deposits: temp_transactions.savings_deposits.sum(:amount),
            withdrawals: temp_transactions.savings_withdrawals.sum(:amount),
            num_days_before_next_transaction: num_days_before_next_transaction,
            interest_per_month: interest_per_month,
            interest_earned_on_deposits: interest_earned_on_deposits,
            withholding_tax_on_deposits: withholding_tax_on_deposits
          }

          records << r
        end

        @data[:records]       = records
        @data[:transactions]  = @account_transactions

        # Interest and tax total
        interest  = 0.00
        tax       = 0.00
        records.each do |o|
          interest += o[:interest_earned_on_deposits]
          tax += o[:withholding_tax_on_deposits]
        end

        @data[:interest]  = interest.round(2)
        @data[:tax]       = tax.round(2)
      end

      @data
    end
  end
end
