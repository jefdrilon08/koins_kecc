module Accounting
  class GenerateGeneralLedger
    def initialize(config:)
      @config = config

      @start_date = @config[:start_date]
      @end_date   = @config[:end_date]
      @branch     = @config[:branch]

      @accounting_code_ids  = @config[:accounting_code_ids] || []

      @data = {
        start_date: @start_date.strftime("%b %d, %Y"),
        end_date: @end_date.strftime("%b %d, %Y"),
        branch: {
          id: @branch.id,
          name: @branch.name
        },
        entries: []
      }
    end

    def execute!
      journal_entries_by_accounting_code  = JournalEntry
                                              .eager_load(:accounting_code, :accounting_entry)
                                              .where(
                                                "accounting_entries.date_posted >= ? AND accounting_entries.date_posted <= ? AND accounting_entries.branch_id = ?",
                                                @start_date,
                                                @end_date,
                                                @branch.id
                                              )
                                              .order("accounting_codes.code ASC, accounting_entries.date_posted ASC, accounting_entries.updated_at ASC")
                                              .group_by(&:accounting_code_id)

      dr_accounting_codes = AccountingCode.joins(
                              journal_entries: :accounting_entry
                            )
                            .where(
                              "journal_entries.post_type = ? AND accounting_entries.date_posted < ? AND accounting_entries.branch_id = ?",
                              "DR",
                              @start_date,
                              @branch.id
                            )
                            .select("accounting_codes.id as accounting_code_id, accounting_codes.name as accounting_code_name, sum(journal_entries.amount) as sum")
                            .group("accounting_codes.id")

      cr_accounting_codes = AccountingCode.joins(
                              journal_entries: :accounting_entry
                            )
                            .where(
                              "journal_entries.post_type = ? AND accounting_entries.date_posted < ? AND accounting_entries.branch_id = ?",
                              "CR",
                              @start_date,
                              @branch.id
                            )
                            .select("accounting_codes.id as accounting_code_id, accounting_codes.name as accounting_code_name, sum(journal_entries.amount) as sum")
                            .group("accounting_codes.id")

      entries = []

      # Fetch accounting codes
      #accounting_codes  = dr_accounting_codes.map{ |o| o.accounting_code_id } | cr_accounting_codes.map{ |o| o.accounting_code_id }
      accounting_codes  = AccountingCode.all.order("code ASC").pluck(:id)

      if @accounting_code_ids.size > 0
        accounting_codes  = AccountingCode.where(id: @accounting_code_ids).order("code ASC").pluck(:id)
      end

      mapped_cr_accounting_codes  = cr_accounting_codes.map{ |o| { id: o.accounting_code_id, name: o.accounting_code_name, sum: o.sum } }
      mapped_dr_accounting_codes  = dr_accounting_codes.map{ |o| { id: o.accounting_code_id, name: o.accounting_code_name, sum: o.sum } }

      accounting_codes  = AccountingCode.where(id: accounting_codes).order("code ASC")

      accounting_codes.each do |accounting_code|
        a = accounting_code.id

        debit_hash  = mapped_dr_accounting_codes.find{ |o| o[:id] == a }
        credit_hash = mapped_cr_accounting_codes.find{ |o| o[:id] == a }

        accounting_code_name  = ""

        if debit_hash.present?
          accounting_code_name  = debit_hash[:name]
        end

        if credit_hash.present?
          accounting_code_name  = credit_hash[:name]
        end

        if accounting_code_name.blank?
          accounting_code_name  = accounting_code.name
        end

        dr_sum  = debit_hash.present? ? debit_hash[:sum].to_f : 0.00 
        cr_sum  = credit_hash.present? ? credit_hash[:sum].to_f : 0.00

        beginning_balance = 0.00

        if accounting_code.debit_entry?
          beginning_balance = dr_sum - cr_sum
        else
          beginning_balance = cr_sum - dr_sum
        end

        running_balance = beginning_balance
        if journal_entries_by_accounting_code[a].present?

          mapped_entries  = journal_entries_by_accounting_code[a].map{ |x|
                              dr_amount       = x.post_type == "DR" ? x.amount.to_f : 0.00
                              cr_amount       = x.post_type == "CR" ? x.amount.to_f : 0.00
                              net_amount      = 0.00

                              if accounting_code.debit_entry?
                                running_balance = running_balance + dr_amount - cr_amount
                                net_amount      = dr_amount - cr_amount
                              else
                                running_balance = running_balance + cr_amount - dr_amount
                                net_amount      = cr_amount - dr_amount
                              end

                              {
                                id: x.id,
                                accounting_code_id: x.accounting_code.id,
                                date_posted: x.accounting_entry.date_posted.strftime("%b %d, %Y"),
                                accounting_entry_id: x.accounting_entry.id,
                                reference_number: x.accounting_entry.reference_number,
                                sub_reference_number: x.accounting_entry.sub_reference_number,
                                book: x.accounting_entry.book,
                                particular: x.accounting_entry.particular,
                                dr_amount: dr_amount,
                                cr_amount: cr_amount,
                                net_amount: net_amount,
                                running_balance: running_balance.to_f
                              }
                            }

          entries << {
            accounting_code_id: a,
            accounting_code_name: accounting_code_name,
            dr_sum: dr_sum.to_f,
            cr_sum: cr_sum.to_f,
            beginning_balance: beginning_balance.to_f,
            ending_balance: running_balance.to_f,
            entries: mapped_entries
          }
        end
      end

      @data[:entries]  = entries
      @data
    end
  end
end
