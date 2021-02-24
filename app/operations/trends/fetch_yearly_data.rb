module Trends
  class FetchYearlyData
    attr_accessor :data,
                  :accounting_code,
                  :branches,
                  :year

    def initialize(year:, branches:, accounting_code:)
      @year             = year
      @branches         = branches
      @accounting_code  = accounting_code

      @data = []
    end

    def execute!
      branches.each do |b|
        d = {
          label: b.name,
          data: [],
          color: b.color || "#f0ffff"
        }

        monthly_accounting_code_summaries = MonthlyAccountingCodeSummary.where(
                                              accounting_code_id: accounting_code.id,
                                              branch_id:          b.id,
                                              year:               year
                                            ).order("month ASC")

        12.times do |m|
          month = m + 1

          entry = monthly_accounting_code_summaries.select{ |o| o.month == month }.first

          if entry.present?
            if accounting_code.debit_entry?
              d[:data] << (entry.dr_amount - entry.cr_amount).round(2)
            elsif accounting_code.credit_entry?
              d[:data] << (entry.cr_amount - entry.dr_amount).round(2)
            else
              raise "Invalid category for accounting code #{accounting_code.id}"
            end
          else
            d[:data] << 0.00
          end
        end

        @data << d
      end

      @data
    end
  end
end
