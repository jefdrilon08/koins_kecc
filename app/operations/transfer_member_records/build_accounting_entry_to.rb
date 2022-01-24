module TransferMemberRecords
  class BuildAccountingEntryTo
    def initialize(config:)
      @config               = config
      @accounting_entry     = @config[:accounting_entry_to]
      @acc_entry_from       = @config[:accounting_entry_from]
      @records              = @config[:record]
      @transfer_member_records    = @config[:transfer_member_records]
      @savings_accounting_codes   = Settings.savings_accounting_codes
      @equity_accounting_codes    = Settings.equity_accounting_codes
      @insurance_accounting_codes = Settings.insurance_accounting_codes
      @branch_settings            = Settings.branch_accounting_codes
    end

    def execute!
   
    @accounting_entry[:debit_journal_entries] = []
    @accounting_entry[:credit_journal_entries] = []
    @accounting_entry[:journal_entries]= []
    @accounting_entry[:particular] = default_particular!
    @accounting_entry[:credit_journal_entries] = build_credit_journal_entries!
    @accounting_entry[:debit_journal_entries] = build_debit_journal_entries!
    

    @accounting_entry[:debit_journal_entries].each do |adbj|

        @accounting_entry[:journal_entries] << {
          id: "",
          post_type: "DR",
          accounting_code_id: adbj[:accounting_code_id],
          accounting_code_name: adbj[:name],
          amount: adbj[:amount].round(2)
        }
      end

      @accounting_entry[:credit_journal_entries].each do |adbj|
        @accounting_entry[:journal_entries] << {
          id: "",
          post_type: "CR",
          accounting_code_id: adbj[:accounting_code_id],
          accounting_code_name: adbj[:name],
          amount: adbj[:amount].round(2)
        }
      end
    
    @accounting_entry
    end

    private

    def build_debit_journal_entries!
      journal_entries = []
      @branch_settings.each do |bs|
        if bs[:branch_id] == @transfer_member_records[:branch_id]
          due_to_acc_code_id = bs[:due_from_accounting_code_id]
          due_to_acc_code = AccountingCode.find(due_to_acc_code_id)
          amount= @accounting_entry[:credit_journal_entries].map{|h| h[:amount]}.sum
          journal_entries << {
            accounting_code_id: due_to_acc_code.id,
            code: due_to_acc_code.code,
            name: due_to_acc_code.name,
            amount: amount.round(2)
          }
        end
      end

      journal_entries
    end

    def build_credit_journal_entries!
      journal_entries = []
      @records.each do |rec|
        rec[:member_accounts].each do |mem|
          if mem[:account_type] == "EQUITY"
            @equity_accounting_codes.each do |eq|
              if eq[:equity_type] == mem[:account_subtype]
                eq_accounting_codes = eq[:deposit_accounting_code_id]
                accnt_code = AccountingCode.find(eq_accounting_codes)
                journal_entries << {
                  accounting_code_id: accnt_code.id,
                  code: accnt_code.code,
                  name: accnt_code.name,
                  amount: mem[:balance].to_f
                }
              end
            end
          elsif mem[:account_type] == "SAVINGS"
            @savings_accounting_codes.each do |sav|
              if sav[:savings_type] == mem[:account_subtype]
                sav_acount_code = sav[:deposit_accounting_code_id]
                accnt_code = AccountingCode.find(sav_acount_code)
                journal_entries << {
                    accounting_code_id: accnt_code.id,
                    code: accnt_code.code,
                    name: accnt_code.name,
                    amount: mem[:balance].to_f
                }
              end
            end
          elsif mem[:account_type] == "INSURANCE"
            @insurance_accounting_codes.each do |ins|
              if ins[:insurance_type] == mem[:account_subtype]
                ins_accounting_code = ins[:deposit_accounting_code_id]
                accnt_code = AccountingCode.find(ins_accounting_code)
                journal_entries << {
                    accounting_code_id: accnt_code.id,
                    code: accnt_code.code,
                    name: accnt_code.name,
                    amount: mem[:balance].to_f
                }
              end
            end
          end
        end
      end
      if journal_entries.count > 1
        journal= journal_entries.group_by { |item|
          [item[:accounting_code_id]]
        }.values.flat_map{|items| items.first.merge(amount: items.sum{|h| h[:amount]})}
        journal_entries = journal
      end
       journal_entries
    end

    def default_particular!
      "To Received Transfer Member/s From #{@acc_entry_from [:branch]} "
    end
  end
end
