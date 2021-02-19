class ProcessAccountingCodeBalance < ApplicationJob
  queue_as :default

  def perform(args)
    branch          = ReadOnlyBranch.find(args[:branch_id])
    accounting_code = ReadOnlyAccountingCode.find(args[:accounting_code_id])
    accounting_fund = ReadOnlyAccountingFund.find_by_id(args[:accounting_fund_id])
    start_date      = args[:start_date].to_date
    end_date        = args[:end_date].to_date

    data  = ::Accounting::TrialBalances::FetchAccountingCodeBalance.new(
              config: {
                accounting_code: accounting_code,
                branch: branch,
                start_date: start_date,
                end_date: end_date
              }
            ).execute!

    accounting_code_balance = AccountingCodeBalance.new(
                                accounting_code:        accounting_code,
                                accounting_fund:        accounting_fund,
                                branch:                 branch,
                                category:               accounting_code.category,
                                start_date:             start_date,
                                end_date:               end_date,
                                total_beginning_debit:  data[:total_beginning_debit],
                                total_beginning_credit: data[:total_beginning_credit],
                                total_current_debit:    data[:total_current_debit],
                                total_current_credit:   data[:total_current_credit],
                                total_ending_debit:     data[:total_ending_debit],
                                total_ending_credit:    data[:total_ending_credit]
                              )

    accounting_code_balance.save!

    accounting_code_ids = AccountingCode.all.pluck(:id)

    accounting_code_balance_ac_ids  = AccountingCodeBalance.select("accounting_code_id")
                                        .where(
                                          accounting_code_id: accounting_code_ids,
                                          accounting_fund_id: accounting_fund.try(:id),
                                          branch_id:          branch.id,
                                          category:           accounting_code.category,
                                          start_date:         start_date,
                                          end_date:           end_date
                                        )

    # Update the data store to done and build trial balance data accordingly
    if accounting_code_ids.size == accounting_code_balance_ac_ids.size
      data_store  = DataStore.trial_balances(
                      "meta->>'branch_id' = ? AND start_date = ? AND end_date = ?",
                      branch.id,
                      start_date,
                      end_date
                    ).first

      if data_store.blank?
        raise "Trial balance not found for branch_id = #{branch.id} start_date = #{start_date} end_date = #{end_date}"
      end

      data_store.data["start_date"] = start_date
      data_store.data["end_date"]   = end_date
      data_store.data["branch"]     = branch
      
      data_store.data["entries"] = []

      accounting_code_balances = AccountingCodeBalance.where(branch_id: branch.id, accounting_fund_id: accounting_fund.try(:id), start_date: start_date, end_date: end_date)

      # ASSETS
      accounting_code_balances.each do |o|
        data_store.data["entries"] << {
          id:               o.accounting_code_id,
          name:             o.accounting_code.name,
          code:             o.accounting_code.code,
          beginning_debit:  o.total_beginning_debit,
          beginning_credit: o.total_beginning_credit,
          current_debit:    o.total_current_debit,
          current_credit:   o.total_current_credit,
          ending_debit:     o.total_ending_debit,
          ending_credit:    o.total_ending_credit
        }
      end

      accounting_code_balances.liabilities.each do |o|
        data_store.data["entries"] << {
          id:               o.accounting_code_id,
          name:             o.accounting_code.name,
          code:             o.accounting_code.code,
          beginning_debit:  o.total_beginning_debit,
          beginning_credit: o.total_beginning_credit,
          current_debit:    o.total_current_debit,
          current_credit:   o.total_current_credit,
          ending_debit:     o.total_ending_debit,
          ending_credit:    o.total_ending_credit
        }
      end

      accounting_code_balances.equities.each do |o|
        data_store.data["entries"] << {
          id:               o.accounting_code_id,
          name:             o.accounting_code.name,
          code:             o.accounting_code.code,
          beginning_debit:  o.total_beginning_debit,
          beginning_credit: o.total_beginning_credit,
          current_debit:    o.total_current_debit,
          current_credit:   o.total_current_credit,
          ending_debit:     o.total_ending_debit,
          ending_credit:    o.total_ending_credit
        }
      end

      accounting_code_balances.fund_balance.each do |o|
        data_store.data["entries"] << {
          id:               o.accounting_code_id,
          name:             o.accounting_code.name,
          code:             o.accounting_code.code,
          beginning_debit:  o.total_beginning_debit,
          beginning_credit: o.total_beginning_credit,
          current_debit:    o.total_current_debit,
          current_credit:   o.total_current_credit,
          ending_debit:     o.total_ending_debit,
          ending_credit:    o.total_ending_credit
        }
      end

      accounting_code_balances.income.each do |o|
        data_store.data["entries"] << {
          id:               o.accounting_code_id,
          name:             o.accounting_code.name,
          code:             o.accounting_code.code,
          beginning_debit:  o.total_beginning_debit,
          beginning_credit: o.total_beginning_credit,
          current_debit:    o.total_current_debit,
          current_credit:   o.total_current_credit,
          ending_debit:     o.total_ending_debit,
          ending_credit:    o.total_ending_credit
        }
      end

      accounting_code_balances.expenses.each do |o|
        data_store.data["entries"] << {
          id:               o.accounting_code_id,
          name:             o.accounting_code.name,
          code:             o.accounting_code.code,
          beginning_debit:  o.total_beginning_debit,
          beginning_credit: o.total_beginning_credit,
          current_debit:    o.total_current_debit,
          current_credit:   o.total_current_credit,
          ending_debit:     o.total_ending_debit,
          ending_credit:    o.total_ending_credit
        }
      end
    end
  end
end
