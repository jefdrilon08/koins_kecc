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

      @data = {
        accounting_code_balances: [],
        pure_savers: [],
        loaners: [],
        active_members: [],
        total_members: []
      }
    end

    def execute!
      build_accounting_code_balances!
      build_member_counts!

      @data
    end

    private

    def build_member_counts!
      branches.each do |b|
        d_pure_savers = {
          label: b.name,
          data: [],
          color: b.color || "#f0ffff"
        }

        d_loaners = {
          label: b.name,
          data: [],
          color: b.color || "#f0ffff"
        }

        d_active_members = {
          label: b.name,
          data: [],
          color: b.color || "#f0ffff"
        }

        d_total_members = {
          label: b.name,
          data: [],
          color: b.color || "#f0ffff"
        }

        12.times do |m|
          month = m + 1

          entry = ReadOnlyDataStore.member_counts.where(
                    "meta ->> 'branch_id' = ? AND EXTRACT(MONTH from as_of) = ? AND EXTRACT(YEAR from as_of) = ?",
                    b.id,
                    month,
                    year
                  ).order("updated_at DESC").first

          if entry.present?
            d_pure_savers[:data]    << entry.data["counts"]["pure_savers"]["total"]
            d_loaners[:data]        << entry.data["counts"]["loaners"]["total"]
            d_active_members[:data] << entry.data["counts"]["active_members"]["total"]
            d_total_members[:data]  << entry.data["counts"]["pure_savers"]["total"] + entry.data["counts"]["loaners"]["total"] + entry.data["counts"]["active_members"]["total"]
          else
            d_pure_savers[:data]    << 0
            d_loaners[:data]        << 0
            d_active_members[:data] << 0
            d_total_members[:data]  << 0
          end
        end

        data[:pure_savers]    << d_pure_savers
        data[:loaners]        << d_loaners
        data[:active_members] << d_active_members
        data[:total_members]  << d_total_members
      end
    end

    def build_accounting_code_balances!
      branches.each do |b|
        d = {
          label: b.name,
          data: [],
          color: b.color || "#f0ffff"
        }

        monthly_accounting_code_summaries = ReadOnlyMonthlyAccountingCodeSummary.where(
                                              accounting_code_id: accounting_code.id,
                                              branch_id:          b.id,
                                              year:               year
                                            ).order("month ASC")

        current_month = Date.today.month

        12.times do |m|
          month = m + 1

          entry = monthly_accounting_code_summaries.select{ |o| o.month == month }.first

          if month <= current_month
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
        end

        @data[:accounting_code_balances] << d
      end
    end
  end
end
