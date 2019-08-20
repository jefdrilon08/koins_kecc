module Accounting
  class GenerateBalanceSheet
    def initialize(config:)
      @config = config
      @year   = @config[:year].to_i
      @branch = @config[:branch]

      @start_date = Date.new(@year)
      @end_date   = Date.new(@year, 12, 31)

      @accounting_code_assets       = AccountingCode.assets
      @accounting_code_liabilities  = AccountingCode.liabilities
      @accounting_code_equities     = AccountingCode.equities
      @accounting_code_expenses     = AccountingCode.expenses
      @accounting_code_income       = AccountingCode.income
      @accounting_code_fund_balance = AccountingCode.fund_balance

      @journal_entries  = JournalEntry.joins(:accounting_entry).where(
                            "accounting_entries.date_posted >= ? AND accounting_entries.date_posted <= ? AND accounting_entries.branch_id = ? AND accounting_entries.status = ?",
                            @start_date,
                            @end_date,
                            @branch.id,
                            "approved"
                          )

      @journal_entries_all  = JournalEntry.joins(:accounting_entry).where(
                                "accounting_entries.date_posted <= ? AND accounting_entries.branch_id = ? AND accounting_entries.status = ?",
                                @end_date,
                                @branch.id,
                                "approved"
                              )

      @data = {
        start_date: @start_date,
        end_date: @end_date,
        assets: [],
        liabilities: [],
        equities: [],
        expenses: [],
        income: [],
        fund_balance: [],
        total_assets: 0.00,
        total_liabilities: 0.00,
        total_equities: 0.00,
        total_expenses: 0.00,
        total_income: 0.00,
        total_fund_balance: 0.00
      }
    end

    def execute!
      build_assets!
      build_liabilities!
      build_equities!
      build_income!
      build_expenses!
      build_fund_balance!

      @data
    end

    private

    # DR
    def build_fund_balance!
      accounting_code_ids = @accounting_code_fund_balance.pluck(:id)

      journal_entries = @journal_entries_all.select{ |o|
                          accounting_code_ids.include?(o.accounting_code_id)
                        }

      @accounting_code_fund_balance.each do |o|
        ac_journal_entries  = journal_entries.select{ |j|
                                j[:accounting_code_id] == o.id
                              }

        total_debit = ac_journal_entries.select{ |a| a[:post_type] == "DR" }.inject(0){ |sum, hash|
                        sum + hash[:amount].to_f.round(2)
                      }

        total_credit  = ac_journal_entries.select{ |a| a[:post_type] == "CR" }.inject(0){ |sum, hash|
                          sum + hash[:amount].to_f.round(2)
                        }

        amount  = (total_debit - total_credit).round(2)

        if amount > 0
          @data[:fund_balance] << {
            accounting_code: {
              id: o.id,
              name: o.name,
              code: o.code,
              category: o.category,
              data: o.data
            },
            amount: amount
          }

          @data[:total_fund_balance] += amount
        end
      end
    end

    # DR
    def build_expenses!
      accounting_code_ids = @accounting_code_expenses.pluck(:id)

      journal_entries = @journal_entries.select{ |o|
                          accounting_code_ids.include?(o.accounting_code_id)
                        }

      @accounting_code_expenses.each do |o|
        ac_journal_entries  = journal_entries.select{ |j|
                                j[:accounting_code_id] == o.id
                              }

        total_debit = ac_journal_entries.select{ |a| a[:post_type] == "DR" }.inject(0){ |sum, hash|
                        sum + hash[:amount].to_f.round(2)
                      }

        total_credit  = ac_journal_entries.select{ |a| a[:post_type] == "CR" }.inject(0){ |sum, hash|
                          sum + hash[:amount].to_f.round(2)
                        }

        amount  = (total_debit - total_credit).round(2)

        if amount > 0
          @data[:expenses] << {
            accounting_code: {
              id: o.id,
              name: o.name,
              code: o.code,
              category: o.category,
              data: o.data
            },
            amount: amount
          }

          @data[:total_expenses] += amount
        end
      end
    end

    # CR
    def build_income!
      accounting_code_ids = @accounting_code_income.pluck(:id)

      journal_entries = @journal_entries.select{ |o|
                          accounting_code_ids.include?(o.accounting_code_id)
                        }

      @accounting_code_income.each do |o|
        ac_journal_entries  = journal_entries.select{ |j|
                                j[:accounting_code_id] == o.id
                              }

        total_debit = ac_journal_entries.select{ |a| a[:post_type] == "DR" }.inject(0){ |sum, hash|
                        sum + hash[:amount].to_f.round(2)
                      }

        total_credit  = ac_journal_entries.select{ |a| a[:post_type] == "CR" }.inject(0){ |sum, hash|
                          sum + hash[:amount].to_f.round(2)
                        }

        amount  = (total_credit - total_debit).round(2)

        if amount > 0
          @data[:income] << {
            accounting_code: {
              id: o.id,
              name: o.name,
              code: o.code,
              category: o.category,
              data: o.data
            },
            amount: amount
          }

          @data[:total_income] += amount
        end
      end
    end

    # CR Account
    def build_equities!
      accounting_code_ids = @accounting_code_equities.pluck(:id)

      journal_entries = @journal_entries_all.select{ |o|
                          accounting_code_ids.include?(o.accounting_code_id)
                        }

      @accounting_code_equities.each do |o|
        ac_journal_entries  = journal_entries.select{ |j|
                                j[:accounting_code_id] == o.id
                              }

        total_debit = ac_journal_entries.select{ |a| a[:post_type] == "DR" }.inject(0){ |sum, hash|
                        sum + hash[:amount].to_f.round(2)
                      }

        total_credit  = ac_journal_entries.select{ |a| a[:post_type] == "CR" }.inject(0){ |sum, hash|
                          sum + hash[:amount].to_f.round(2)
                        }

        amount  = (total_credit - total_debit).round(2)

        if amount > 0
          @data[:equities] << {
            accounting_code: {
              id: o.id,
              name: o.name,
              code: o.code,
              category: o.category,
              data: o.data
            },
            amount: amount
          }

          @data[:total_equities] += amount
        end
      end
    end

    # CR Account
    def build_liabilities!
      accounting_code_ids = @accounting_code_liabilities.pluck(:id)

      journal_entries = @journal_entries_all.select{ |o|
                          accounting_code_ids.include?(o.accounting_code_id)
                        }

      @accounting_code_liabilities.each do |o|
        ac_journal_entries  = journal_entries.select{ |j|
                                j[:accounting_code_id] == o.id
                              }

        total_debit = ac_journal_entries.select{ |a| a[:post_type] == "DR" }.inject(0){ |sum, hash|
                        sum + hash[:amount].to_f.round(2)
                      }

        total_credit  = ac_journal_entries.select{ |a| a[:post_type] == "CR" }.inject(0){ |sum, hash|
                          sum + hash[:amount].to_f.round(2)
                        }

        amount  = (total_credit - total_debit).round(2)

        if amount > 0
          @data[:liabilities] << {
            accounting_code: {
              id: o.id,
              name: o.name,
              code: o.code,
              category: o.category,
              data: o.data
            },
            amount: amount
          }

          @data[:total_liabilities] += amount
        end
      end
    end

    # DR Account
    def build_assets!
      accounting_code_ids = @accounting_code_assets.pluck(:id)

      journal_entries = @journal_entries_all.select{ |o|
                          accounting_code_ids.include?(o.accounting_code_id)
                        }

      @accounting_code_assets.each do |o|
        ac_journal_entries  = journal_entries.select{ |j|
                                j[:accounting_code_id] == o.id
                              }

        total_debit = ac_journal_entries.select{ |a| a[:post_type] == "DR" }.inject(0){ |sum, hash|
                        sum + hash[:amount].to_f.round(2)
                      }

        total_credit  = ac_journal_entries.select{ |a| a[:post_type] == "CR" }.inject(0){ |sum, hash|
                          sum + hash[:amount].to_f.round(2)
                        }

        amount  = (total_debit - total_credit).round(2)

        if amount > 0
          @data[:assets] << {
            accounting_code: {
              id: o.id,
              name: o.name,
              code: o.code,
              category: o.category,
              data: o.data
            },
            amount: amount
          }

          @data[:total_assets] += amount
        end
      end
    end
  end
end
