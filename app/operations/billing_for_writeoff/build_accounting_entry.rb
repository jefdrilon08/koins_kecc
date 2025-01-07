module BillingForWriteoff
  class BuildAccountingEntry
    def initialize(config:)
      @config = config[:data]
      @accounting_entry = @config[:accounting_entry]
      @records= @config[:record]
      @accounting_codes_for_writeoff = Settings.loan_product_accounting_codes_for_writeoff
    end

    def execute!
    @accounting_entry[:debit_journal_entries] = []
    @accounting_entry[:credit_journal_entries] = []
    @accounting_entry[:journal_entries]= []
    @accounting_entry[:particular] = default_particular!
    debit_journal_entries = build_debit_journal_entries!
    credit_journal_entries = build_credit_journal_entries!
    @accounting_entry[:debit_journal_entries] = debit_journal_entries
    @accounting_entry[:credit_journal_entries] = credit_journal_entries


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
      @records.each do |rec|
        @accounting_codes_for_writeoff.each do |acw|
          if rec[:loan][:loan_product_id] == acw[:loan_product_id]
            db_acc_code_id = acw.allowance_for_impairment_losses_accounting_code_id
            db_accounting_code= AccountingCode.find(db_acc_code_id)

              journal_entries << {
                accounting_code_id: db_accounting_code.id,
                code: db_accounting_code.code,
                loan_product_id: rec[:loan][:loan_product_id],
                name: db_accounting_code.name,
                amount: rec[:amount]
              }
          
          end

        end
      end

      if journal_entries.count > 1 
        #get all same loan product and sum the amount
        journal= journal_entries.group_by { |item|
          [item[:loan_product_id]]
        }.values.flat_map{|items| items.first.merge(amount: items.sum{|h| h[:amount]})}
        journal_entries = journal
        journal_entries
      else
        journal_entries
      end
    end

    def build_credit_journal_entries!
      journal_entries = []
      @records.each do |rec|
        @accounting_codes_for_writeoff.each do |acw|
          if rec[:loan][:loan_product_id] == acw[:loan_product_id]
            cr_acc_code_id = acw.receivable_accounting_code_id
            cr_accounting_code= AccountingCode.find(cr_acc_code_id)

              journal_entries << {
                accounting_code_id: cr_accounting_code.id,
                code: cr_accounting_code.code,
                loan_product_id: rec[:loan][:loan_product_id],
                name: cr_accounting_code.name,
                amount: rec[:amount]
              }
          
          end

        end
      end

      if journal_entries.count > 1 
        #get all same loan product and sum the amount
        journal= journal_entries.group_by { |item|
          [item[:loan_product_id]]
        }.values.flat_map{|items| items.first.merge(amount: items.sum{|h| h[:amount]})}
        journal_entries = journal
        journal_entries
      else
        journal_entries
      end
    end

    def default_particular!
      "TO WRITE OFF DELIQUENT ACCOUNTS FOR SATO - #{@accounting_entry[:branch]} JANUARY-JUNE YEAR 2022"
    end
  end
end
