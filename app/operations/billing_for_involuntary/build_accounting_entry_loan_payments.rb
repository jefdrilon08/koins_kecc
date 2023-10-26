module BillingForInvoluntary
    class BuildAccountingEntryLoanPayments
        def initialize(config:)
            @config = config      
            @accounting_entry = @config[:accounting_entry_loan_payment]
            @records = @config[:records]
            @loan_product_settings  = Settings.loan_product_accounting_codes
            @resignation_settings         = Settings.resignation
            @closing_fee_accounting_code  = AccountingCode.find(@resignation_settings.closing_fee_accounting_code_id)
            @deposits_accounting_code     = AccountingCode.find(@resignation_settings.deposits_accounting_code_id)
            @savings_accounting_codes   = Settings.savings_accounting_codes
        end

        def execute!
            @accounting_entry[:debit_journal_entries] = []
            @accounting_entry[:credit_journal_entries]  = []
            @accounting_entry[:journal_entries] = []
            @accounting_entry[:debit_journal_entries] = build_debit_journal_entries!
            @accounting_entry[:credit_journal_entries] = build_credit_journal_entries!
            

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
                journal_entries =   []
                    @records.each do |rec|
                        due_to_members = 0.0
                        rec[:member_accounts].each do |ma|
                            due_to_members += ma[:balance]
                        end
                        rec[:member_accounts].each do |ma|
                            if ma[:account_type] == "SAVINGS" and ma[:account_subtype] == "K-IMPOK"
                                @savings_accounting_codes.each do |sav|
                                    if sav[:savings_type] == ma[:account_subtype]
                                        deposit_accounting_code_id = sav[:deposit_accounting_code_id]
                                        acc_code = AccountingCode.find(deposit_accounting_code_id)
                                        journal_entries << {
                                        accounting_code_id: acc_code.id,
                                        code: acc_code.code,
                                        name: acc_code.name,
                                        amount: due_to_members.round(2).to_f
                                        }
                                    end
                                end
                            end
                        end
                        
                    
                    end
                if journal_entries.count > 1
                    journal = journal_entries.group_by {|item| [item[:accounting_code_id]]}.values.flat_map{|items| items.first.merge(amount: items.sum{|h| h[:amount]})}
                    journal_entries = journal
                end
                journal_entries
            end

            def build_credit_journal_entries!
                journal_entries = []
                    @records.each do |rec|
                        rec[:loan_records].each do |lr|
                           loan_product = Loan.find(lr[:id]).loan_product
                           @loan_product_settings.each do |lrs|
                                if loan_product.id == lrs[:loan_product_id]
                                    interest_accounting_code = AccountingCode.find(lrs[:interest_receivable_accounting_code_id])
                                    receivable_account_code = AccountingCode.find(lrs[:receivable_accounting_code_id])
                                    if lr[:interest_balance].to_f > 0.0
                                        journal_entries << {
                                            accounting_code_id: interest_accounting_code.id,
                                            code: interest_accounting_code.code,
                                            name: interest_accounting_code.name,
                                            amount: lr[:interest_balance].round(2).to_f
                                        }
                                    end

                                    if lr[:principal_balance].to_f > 0.0
                                        journal_entries << {
                                            accounting_code_id: receivable_account_code.id,
                                            code: receivable_account_code.code,
                                            name: receivable_account_code.name,
                                            amount: lr[:principal_balance].round(2).to_f
                                        }
                                    end
                                end
                            end
                        end

                        if rec[:closing_fee_amount] > 0.0
                            @closing_fee_accounting_code
                            journal_entries << {
                                accounting_code_id: @closing_fee_accounting_code.id,
                                code: @closing_fee_accounting_code.code,
                                name: @closing_fee_accounting_code.name,
                                amount: rec[:closing_fee_amount].round(2).to_f
                            }
                        end
                        
                    end
                if journal_entries.count > 1
                    journal = journal_entries.group_by {|item| [item[:accounting_code_id]]}.values.flat_map{|items| items.first.merge(amount: items.sum{|h| h[:amount]})}
                    journal_entries = journal
                end
                
                journal_entries
               
            end
    
    
    end
end