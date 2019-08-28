module Accounting
  class FormatTrialBalance
    def initialize(trial_balance_data:)
      @trial_balance_data = trial_balance_data

      @data = {
        start_date: @trial_balance_data[:start_date],
        end_date: @trial_balance_data[:end_date],
        branch: @trial_balance_data[:branch],
        total_beginning_debit: @trial_balance_data[:total_beginning_debit],
        total_beginning_credit: @trial_balance_data[:total_beginning_credit],
        total_current_debit: @trial_balance_data[:total_current_debit],
        total_current_credit: @trial_balance_data[:total_current_credit],
        total_ending_debit: @trial_balance_data[:total_ending_debit],
        total_ending_credit: @trial_balance_data[:total_ending_credit],
        entries: []
      }
    end

    def execute!
      @trial_balance_data[:accounting_codes].each_with_index do |o, i|
        if  @trial_balance_data[:beginning_entries][i][:dr_amount] != 0.00 or
            @trial_balance_data[:beginning_entries][i][:cr_amount] != 0.00 or
            @trial_balance_data[:current_entries][i][:dr_amount] != 0.00 or
            @trial_balance_data[:current_entries][i][:cr_amount] != 0.00 or
            @trial_balance_data[:ending_entries][i][:dr_amount] != 0.00 or
            @trial_balance_data[:ending_entries][i][:cr_amount] != 0.00

          @data[:entries] << {
            id: o[:id],
            name: o[:name],
            code: o[:code],
            beginning_debit: @trial_balance_data[:beginning_entries][i][:dr_amount],
            beginning_credit: @trial_balance_data[:beginning_entries][i][:cr_amount],
            current_debit: @trial_balance_data[:current_entries][i][:dr_amount],
            current_credit: @trial_balance_data[:current_entries][i][:cr_amount],
            ending_debit: @trial_balance_data[:ending_entries][i][:dr_amount],
            ending_credit: @trial_balance_data[:ending_entries][i][:cr_amount]
          }
        end
      end

      @data[:entries] << {
        id: "",
        name: "TOTAL",
        beginning_debit: @data[:total_beginning_debit],
        beginning_credit: @data[:total_beginning_credit],
        current_debit: @data[:total_current_debit],
        current_credit: @data[:total_current_credit],
        ending_debit: @data[:total_ending_debit],
        ending_credit: @data[:total_ending_credit]
      }

      @data
    end
  end
end
