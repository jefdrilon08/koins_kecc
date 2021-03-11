module Accounting
  module TrialBalances
    class DeriveFromGeneralLedger
      attr_accessor :gl_data,
                    :data

      def initialize(gl_data:)
        @gl_data  = gl_data

        @data = {
          start_date:             @gl_data["start_date"],
          end_date:               @gl_data["end_date"],
          branch:                 @gl_data["branch"],
          entries:                []
        }
      end

      def execute!
        @accounting_codes = ReadOnlyAccountingCode.where(
                              id: @gl_data["entries"].map{ |o| o["accounting_code_id"] }
                            ).order("code ASC")


        @accounting_codes.each do |accounting_code|
          gl_entry = @gl_data["entries"].select{ |o| o["accounting_code_id"] == accounting_code.id }.first

          entry = {
            id:               accounting_code.id,
            name:             accounting_code.name,
            code:             accounting_code.code,
            beginning_debit:  0.00,
            beginning_credit: 0.00,
            current_debit:    0.00,
            current_credit:   0.00,
            ending_debit:     0.00,
            entry_credit:     0.00
          }

          if accounting_code.debit_entry?
            entry[:beginning_debit] = gl_entry["beginning_balance"].to_f.round(2)
          elsif accounting_code.credit_entry?
            entry[:beginning_credit]  = gl_entry["beginning_balance"].to_f.round(2)
          else
            raise "Invalid category for accounting_code #{accounting_code.id}"
          end

          entry[:current_debit]   = gl_entry["entries"].inject(0){ |sum, o| sum + o["dr_amount"] }.to_f.round(2)
          entry[:current_credit]  = gl_entry["entries"].inject(0){ |sum, o| sum + o["cr_amount"] }.to_f.round(2)

          entry[:ending_debit]   = (entry[:beginning_debit] + entry[:current_debit]).to_f.round(2)
          entry[:ending_credit]  = (entry[:beginning_credit] + entry[:current_credit]).to_f.round(2)

          if accounting_code.debit_entry?
            net = (entry[:ending_debit] - entry[:ending_credit]).to_f.round(2)

            if net < 0
              entry[:ending_credit] = (net * -1)
              entry[:ending_debit]  = 0.00
            else
              entry[:ending_debit]  = net
              entry[:ending_credit] = 0.00
            end
          elsif accounting_code.credit_entry?
            net = (entry[:ending_credit] - entry[:ending_debit]).to_f.round(2)

            if net < 0
              entry[:ending_debit]  = (net * -1)
              entry[:ending_credit] = 0.00
            else
              entry[:ending_credit] = net
              entry[:ending_debit]  = 0.00
            end
          end

          if entry[:beginning_debit] > 0 or entry[:beginning_credit] > 0 or entry[:current_debit] > 0 or entry[:current_credit] > 0 or entry[:ending_debit] > 0 or entry[:ending_credit] > 0
            @data[:entries] << entry
          end
        end

        # Totals
        @data[:entries] << {
          id:               "",
          code:             "",
          name:             "TOTAL",
          beginning_debit:  @data[:entries].inject(0){ |sum, o| sum + o[:beginning_debit] }.to_f.round(2),
          beginning_credit: @data[:entries].inject(0){ |sum, o| sum + o[:beginning_credit] }.to_f.round(2),
          current_debit:    @data[:entries].inject(0){ |sum, o| sum + o[:current_debit] }.to_f.round(2),
          current_credit:   @data[:entries].inject(0){ |sum, o| sum + o[:current_credit] }.to_f.round(2),
          ending_debit:     @data[:entries].inject(0){ |sum, o| sum + o[:ending_debit] }.to_f.round(2),
          ending_credit:    @data[:entries].inject(0){ |sum, o| sum + o[:ending_credit] }.to_f.round(2)
        }

        @data
      end
    end
  end
end
