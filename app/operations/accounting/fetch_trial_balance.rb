module Accounting
  class FetchTrialBalance
    def initialize(config:)
      @config           = config
      @start_date       = @config[:start_date]
      @end_date         = @config[:end_date]
      @branch           = @config[:branch]
      @accounting_fund  = @config[:accounting_fund]

      @data = {
        start_date: @start_date,
        end_date: @end_date,
        beginning_assets: {},
        beginning_liabilities: {},
        beginning_equities: {},
        beginning_income: {},
        beginning_expenses: {},
        beginning_fund_balances: {},
        current_assets: {},
        current_liabilities: {},
        current_equities: {},
        current_income: {},
        current_expenses: {},
        current_fund_balances: {},
        ending_assets: {},
        ending_liabilities: {},
        ending_equities: {},
        ending_income: {},
        ending_expenses: {},
        ending_fund_balances: {},
        entries: [],
        total_beginning_debit: 0.00,
        total_beginning_credit: 0.00,
        total_current_debit: 0.00,
        total_current_credit: 0.00,
        total_ending_debit: 0.00,
        total_ending_credit: 0.00
      }
    end

    def execute!
      # Assets
      @config[:category]  = "ASSETS"

      @data[:beginning_assets]  = ::Accounting::FetchBeginningBalances.new(
                                    config: @config
                                  ).execute!

      @data[:current_assets]  = ::Accounting::FetchCurrentBalances.new(
                                  config: @config
                                ).execute!

      @data[:ending_assets] = ::Accounting::FetchEndingBalances.new(
                                config: @config
                              ).execute!

      # Liabilities
      @config[:category]  = "LIABILITIES"

      @data[:beginning_liabilities] = ::Accounting::FetchBeginningBalances.new(
                                        config: @config
                                      ).execute!

      @data[:current_liabilities] = ::Accounting::FetchCurrentBalances.new(
                                      config: @config
                                    ).execute!

      @data[:ending_liabilities]  = ::Accounting::FetchEndingBalances.new(
                                      config: @config
                                    ).execute!

      # Equities
      @config[:category]  = "EQUITIES"

      @data[:beginning_equities]  = ::Accounting::FetchBeginningBalances.new(
                                      config: @config
                                    ).execute!

      @data[:current_equities]  = ::Accounting::FetchCurrentBalances.new(
                                    config: @config
                                  ).execute!

      @data[:ending_equities] = ::Accounting::FetchEndingBalances.new(
                                  config: @config
                                ).execute!

      # Income
      @config[:category]  = "INCOME"

      @data[:beginning_income]  = ::Accounting::FetchBeginningBalances.new(
                                    config: @config
                                  ).execute!

      @data[:current_income]  = ::Accounting::FetchCurrentBalances.new(
                                  config: @config
                                ).execute!

      @data[:ending_income] = ::Accounting::FetchEndingBalances.new(
                                config: @config
                              ).execute!

      # Expenses
      @config[:category]  = "EXPENSES"

      @data[:beginning_expenses]  = ::Accounting::FetchBeginningBalances.new(
                                      config: @config
                                    ).execute!

      @data[:current_expenses]  = ::Accounting::FetchCurrentBalances.new(
                                    config: @config
                                  ).execute!

      @data[:ending_expenses] = ::Accounting::FetchEndingBalances.new(
                                  config: @config
                                ).execute!

      # Fund Balance
      @config[:category]  = "FUND BALANCE"

      @data[:beginning_fund_balances] = ::Accounting::FetchBeginningBalances.new(
                                          config: @config
                                        ).execute!

      @data[:current_fund_balances] = ::Accounting::FetchCurrentBalances.new(
                                        config: @config
                                      ).execute!

      @data[:ending_fund_balances]  = ::Accounting::FetchEndingBalances.new(
                                        config: @config
                                      ).execute!

      @data[:total_beginning_debit] += @data[:beginning_assets][:total_beginning_debit] 
      @data[:total_beginning_debit] += @data[:beginning_liabilities][:total_beginning_debit]
      @data[:total_beginning_debit] += @data[:beginning_equities][:total_beginning_debit]
      @data[:total_beginning_debit] += @data[:beginning_income][:total_beginning_debit]
      @data[:total_beginning_debit] += @data[:beginning_expenses][:total_beginning_debit]
      @data[:total_beginning_debit] += @data[:beginning_fund_balances][:total_beginning_debit]

      @data[:total_beginning_credit] += @data[:beginning_assets][:total_beginning_credit]
      @data[:total_beginning_credit] += @data[:beginning_liabilities][:total_beginning_credit]
      @data[:total_beginning_credit] += @data[:beginning_equities][:total_beginning_credit]
      @data[:total_beginning_credit] += @data[:beginning_income][:total_beginning_credit]
      @data[:total_beginning_credit] += @data[:beginning_expenses][:total_beginning_credit]
      @data[:total_beginning_credit] += @data[:beginning_fund_balances][:total_beginning_credit]

      @data[:total_current_debit] += @data[:current_assets][:total_current_debit] 
      @data[:total_current_debit] += @data[:current_liabilities][:total_current_debit]
      @data[:total_current_debit] += @data[:current_equities][:total_current_debit]
      @data[:total_current_debit] += @data[:current_income][:total_current_debit]
      @data[:total_current_debit] += @data[:current_expenses][:total_current_debit]
      @data[:total_current_debit] += @data[:current_fund_balances][:total_current_debit]

      @data[:total_current_credit] += @data[:current_assets][:total_current_credit]
      @data[:total_current_credit] += @data[:current_liabilities][:total_current_credit]
      @data[:total_current_credit] += @data[:current_equities][:total_current_credit]
      @data[:total_current_credit] += @data[:current_income][:total_current_credit]
      @data[:total_current_credit] += @data[:current_expenses][:total_current_credit]
      @data[:total_current_credit] += @data[:current_fund_balances][:total_current_credit]

      @data[:total_ending_debit] += @data[:ending_assets][:total_ending_debit] 
      @data[:total_ending_debit] += @data[:ending_liabilities][:total_ending_debit]
      @data[:total_ending_debit] += @data[:ending_equities][:total_ending_debit]
      @data[:total_ending_debit] += @data[:ending_income][:total_ending_debit]
      @data[:total_ending_debit] += @data[:ending_expenses][:total_ending_debit]
      @data[:total_ending_debit] += @data[:ending_fund_balances][:total_ending_debit]

      @data[:total_ending_credit] += @data[:ending_assets][:total_ending_credit]
      @data[:total_ending_credit] += @data[:ending_liabilities][:total_ending_credit]
      @data[:total_ending_credit] += @data[:ending_equities][:total_ending_credit]
      @data[:total_ending_credit] += @data[:ending_income][:total_ending_credit]
      @data[:total_ending_credit] += @data[:ending_expenses][:total_ending_credit]
      @data[:total_ending_credit] += @data[:ending_fund_balances][:total_ending_credit]

      build_entries!

      @data
    end

    private

    def build_entries!
      @data[:beginning_assets][:beginning_entries].each_with_index do |o, i|
        @data[:entries] << {
          id: o[:accounting_code][:id],
          name: o[:accounting_code][:name],
          code: o[:accounting_code][:code],
          beginning_debit: o[:total_beginning_debit],
          beginning_credit: o[:total_beginning_credit],
          current_debit: @data[:current_assets][:current_entries][i][:total_current_debit],
          current_credit: @data[:current_assets][:current_entries][i][:total_current_credit],
          ending_debit: @data[:ending_assets][:ending_entries][i][:total_ending_debit],
          ending_credit: @data[:ending_assets][:ending_entries][i][:total_ending_credit]
        }
      end

      @data[:beginning_liabilities][:beginning_entries].each_with_index do |o, i|
        @data[:entries] << {
          id: o[:accounting_code][:id],
          name: o[:accounting_code][:name],
          code: o[:accounting_code][:code],
          beginning_debit: o[:total_beginning_debit],
          beginning_credit: o[:total_beginning_credit],
          current_debit: @data[:current_liabilities][:current_entries][i][:total_current_debit],
          current_credit: @data[:current_liabilities][:current_entries][i][:total_current_credit],
          ending_debit: @data[:ending_liabilities][:ending_entries][i][:total_ending_debit],
          ending_credit: @data[:ending_liabilities][:ending_entries][i][:total_ending_credit]
        }
      end

      @data[:beginning_equities][:beginning_entries].each_with_index do |o, i|
        @data[:entries] << {
          id: o[:accounting_code][:id],
          name: o[:accounting_code][:name],
          code: o[:accounting_code][:code],
          beginning_debit: o[:total_beginning_debit],
          beginning_credit: o[:total_beginning_credit],
          current_debit: @data[:current_equities][:current_entries][i][:total_current_debit],
          current_credit: @data[:current_equities][:current_entries][i][:total_current_credit],
          ending_debit: @data[:ending_equities][:ending_entries][i][:total_ending_debit],
          ending_credit: @data[:ending_equities][:ending_entries][i][:total_ending_credit]
        }
      end

      @data[:beginning_income][:beginning_entries].each_with_index do |o, i|
        @data[:entries] << {
          id: o[:accounting_code][:id],
          name: o[:accounting_code][:name],
          code: o[:accounting_code][:code],
          beginning_debit: o[:total_beginning_debit],
          beginning_credit: o[:total_beginning_credit],
          current_debit: @data[:current_income][:current_entries][i][:total_current_debit],
          current_credit: @data[:current_income][:current_entries][i][:total_current_credit],
          ending_debit: @data[:ending_income][:ending_entries][i][:total_ending_debit],
          ending_credit: @data[:ending_income][:ending_entries][i][:total_ending_credit]
        }
      end

      @data[:beginning_expenses][:beginning_entries].each_with_index do |o, i|
        @data[:entries] << {
          id: o[:accounting_code][:id],
          name: o[:accounting_code][:name],
          code: o[:accounting_code][:code],
          beginning_debit: o[:total_beginning_debit],
          beginning_credit: o[:total_beginning_credit],
          current_debit: @data[:current_expenses][:current_entries][i][:total_current_debit],
          current_credit: @data[:current_expenses][:current_entries][i][:total_current_credit],
          ending_debit: @data[:ending_expenses][:ending_entries][i][:total_ending_debit],
          ending_credit: @data[:ending_expenses][:ending_entries][i][:total_ending_credit]
        }
      end

      @data[:beginning_fund_balances][:beginning_entries].each_with_index do |o, i|
        @data[:entries] << {
          id: o[:accounting_code][:id],
          name: o[:accounting_code][:name],
          code: o[:accounting_code][:code],
          beginning_debit: o[:total_beginning_debit],
          beginning_credit: o[:total_beginning_credit],
          current_debit: @data[:current_fund_balance][:current_entries][i][:total_current_debit],
          current_credit: @data[:current_fund_balance][:current_entries][i][:total_current_credit],
          ending_debit: @data[:ending_fund_balance][:ending_entries][i][:total_ending_debit],
          ending_credit: @data[:ending_fund_balance][:ending_entries][i][:total_ending_credit]
        }
      end
    end
  end
end
