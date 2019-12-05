module Closing
  class ComputeYearEndClosing
    def initialize(config:)
      @config       = config
      @closing_date = @config[:closing_date].try(:to_date) || Date.today
      @year         = @config[:year].try(:to_i) || @closing_date.year
      @particular   = @config[:particular] || default_particular
      @user         = @config[:user]
      @branch       = @config[:branch]

      @accounting_fund  = @config[:accounting_fund] || nil

      @expenses_accounting_codes  = AccountingCode.expenses
      @income_accounting_codes    = AccountingCode.income

      if @accounting_fund.present?
        settings  = Settings.accounting_fund_year_end_closing_entries.select{ |o|
                      o.accounting_fund_id == @accounting_fund.id
                    }.first

        if settings.blank?
          raise "Settings for accounting fund #{@accounting_fund.id} not found (year end closing)"
        else
          if settings.accounting_entry_id.blank?
            raise "Accounting entry id not found for accounting fund settings #{@accounting_fund.id} (year end closing)"
          end
        end

        @net_closing_accounting_code  = AccountingCode.find(settings.accounting_entry_id)
      else
        @net_closing_accounting_code  = AccountingCode.find(Settings.net_closing_accounting_code_id)
      end

      @data = {
        year: @year,
        closing_date: @closing_date,
        particular: @particular,
        original_entries: {
          debit: [],
          credit: [],
          amount_debit: 0.00,
          amount_credit: 0.00
        },
        closing_entries: {
          debit: [],
          credit: [],
          amount_debit: 0.00,
          amount_credit: 0.00
        },
        net_entry: {
          accounting_code: nil,
          debit: 0.00,
          credit: 0.00
        }
      }
    end

    def execute!  
      build_original_entries!
      build_closing_entries!
      build_accounting_entry!
      @data
    end

    private

    def default_particular
      "To close the year #{@year} dated #{@closing_date}"
    end

    def build_accounting_entry!
      @data[:accounting_entry]  = ::Closing::BuildAccountingEntry.new(
                                    config: {
                                      data: @data,
                                      prepared_by: @user.full_name,
                                      particular: @particular,
                                      branch: @branch,
                                      accounting_fund: @accounting_fund
                                    }
                                  ).execute!
    end

    def build_closing_entries!
      # Flip credit to debit
      @data[:original_entries][:credit].each do |e|
        d = {
          accounting_code: e[:accounting_code],
          debit: e[:credit],
          credit: e[:debit]
        }

        @data[:closing_entries][:debit] << d
      end

      # Flip debit to credit
      @data[:original_entries][:debit].each do |e|
        d = {
          accounting_code: e[:accounting_code],
          debit: e[:credit],
          credit: e[:debit]
        }

        @data[:closing_entries][:credit] << d
      end

      # Final closing entry
      net_debit   = 0.00
      net_credit  = 0.00

      if @data[:original_entries][:amount_debit] > @data[:original_entries][:amount_credit]
        net_debit   = (@data[:original_entries][:amount_debit] - @data[:original_entries][:amount_credit]).round(2)
      elsif @data[:original_entries][:amount_credit] > @data[:original_entries][:amount_debit]
        net_credit  = (@data[:original_entries][:amount_credit] - @data[:original_entries][:amount_debit]).round(2)
      end

      @data[:net_entry] = {
        accounting_code: @net_closing_accounting_code,
        debit: net_debit,
        credit: net_credit
      }

      # Put to debit/credit
      if net_debit > 0
        @data[:closing_entries][:amount_debit] += net_debit
        @data[:closing_entries][:debit] << @data[:net_entry]
      elsif net_credit > 0
        @data[:closing_entries][:amount_credit] += net_credit
        @data[:closing_entries][:credit] << @data[:net_entry]
      end
    end

    def build_original_entries!
      # Expense entries: debit accounts
      @expenses_accounting_codes.each do |a|
        debit_entries = JournalEntry.debit.joins(:accounting_entry).where(
                          "accounting_entries.status = ? AND accounting_code_id = ? AND accounting_entries.branch_id = ? AND EXTRACT(year FROM accounting_entries.date_posted) = ?",
                          "approved",
                          a.id,
                          @branch.id,
                          @year
                        )

        credit_entries  = JournalEntry.credit.joins(:accounting_entry).where(
                            "accounting_entries.status = ? AND accounting_code_id = ? AND accounting_entries.branch_id = ? AND EXTRACT(year FROM accounting_entries.date_posted) = ?",
                            "approved",
                            a.id,
                            @branch.id,
                            @year
                          )

        if @accounting_fund.present?
          debit_entries   = debit_entries.where("accounting_entries.accounting_fund_id = ?", @accounting_fund.id)
          credit_entries  = credit_entries.where("accounting_entries.accounting_fund_id = ?", @accounting_fund.id)
        end


        total_debit   = debit_entries.sum(:amount).round(2)
        total_credit  = credit_entries.sum(:amount).round(2)
        net           = (total_debit - total_credit).round(2)

        if net != 0
          if net > 0
            @data[:original_entries][:amount_debit] += net

            d = {
              accounting_code: a,
              debit: net,
              credit: 0.00
            }

            @data[:original_entries][:debit] << d
          else
            net = net * -1

            @data[:original_entries][:amount_credit] += net

            d = {
              accounting_code: a,
              debit: 0.00,
              credit: net
            }

            @data[:original_entries][:credit] << d
          end
        end
      end

      # Income entries: credit accounts
      @income_accounting_codes.each do |a|
        debit_entries = JournalEntry.debit.joins(:accounting_entry).where(
                          "accounting_entries.status = ? AND accounting_code_id = ? AND accounting_entries.branch_id = ? AND EXTRACT(year FROM accounting_entries.date_posted) = ?",
                          "approved",
                          a.id,
                          @branch.id,
                          @year
                        )

        credit_entries  = JournalEntry.credit.joins(:accounting_entry).where(
                            "accounting_entries.status = ? AND accounting_code_id = ? AND accounting_entries.branch_id = ? AND EXTRACT(year FROM accounting_entries.date_posted) = ?",
                            "approved",
                            a.id,
                            @branch.id,
                            @year
                          )

        if @accounting_fund.present?
          debit_entries   = debit_entries.where("accounting_entries.accounting_fund_id = ?", @accounting_fund.id)
          credit_entries  = credit_entries.where("accounting_entries.accounting_fund_id = ?", @accounting_fund.id)
        end

        total_debit   = debit_entries.sum(:amount).round(2)
        total_credit  = credit_entries.sum(:amount).round(2)
        net           = (total_credit - total_debit).round(2)

        if net != 0
          if net > 0
            @data[:original_entries][:amount_credit] += net

            d = {
              accounting_code: a,
              debit: 0.00,
              credit: net
            }

            @data[:original_entries][:credit] << d
          else
            net = net * -1

            @data[:original_entries][:amount_debit] += net

            d = {
              accounting_code: a,
              debit: net,
              credit: 0.00
            }

            @data[:original_entries][:debit] << d
          end
        end

      end
    end
  end
end
