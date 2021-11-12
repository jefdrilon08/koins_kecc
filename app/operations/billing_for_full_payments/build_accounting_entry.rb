module BillingForFullPayments
  class BuildAccountingEntry
    def initialize(full_payment_billing:, current_user:)
      
      @user =  current_user
      @full_payment_billing = full_payment_billing
      @billing_header = @full_payment_billing.meta["header"]
      @book         = @full_payment_billing.meta["data"]["book"]
      @prepared_by  = @user.full_name
      @particular   = @full_payment_billing.meta["data"]["particular"]
      @or_number   = @full_payment_billing.meta["data"]["OR"]
      @ar_number   = @full_payment_billing.meta["data"]["AR"]
      @branch = Branch.find(@full_payment_billing.meta["branch_id"]) 
      @current_date = ::Utils::GetCurrentDate.new(
                        config: {
                          branch: @branch
                        }
                      ).execute!
      @accounting_entry_data  = {
        book: @book,
        date_prepared: @current_date.strftime("%B %d, %Y"),
        company_name: Settings.company_name,
        company_address: Settings.company_address,
        branch: @branch.to_s.upcase,
        prepared_by: @prepared_by,
        particular: @particular,
        debit_journal_entries: [],
        credit_journal_entries: [],
        journal_entries: [],
        branch_id: @branch.id,
        branch_name: @branch.name,
        status: "display",
        data: {
          or_number: @or_number ,
          ar_number: @ar_number,
        }
      }
      
    end
    def execute!
      #raise build_credit_journal_entries!.inspect
      @accounting_entry_data[:credit_journal_entries]  = build_credit_journal_entries!
      @accounting_entry_data[:debit_journal_entries]  = build_debit_journal_entries!
      #build journal entries
      @accounting_entry_data[:credit_journal_entries].each do |j|
        @accounting_entry_data[:journal_entries] << {
          id: "",
          post_type: "DR",
          accounting_code_id: j[:accounting_code_id],
          accounting_code_name: j[:name],
          amount: j[:amount]
        }
      end
      @accounting_entry_data[:debit_journal_entries].each do |j|
        @accounting_entry_data[:journal_entries] << {
          id: "",
          post_type: "CR",
          accounting_code_id: j[:accounting_code_id],
          accounting_code_name: j[:name],
          amount: j[:amount]
        }
      end
      
      @accounting_entry_data
      
    end

    private
    
    
    def build_debit_journal_entries! #credit
      journal_entries = []
      @billing_header[0].each do |bh|
        accounting_code_wp = AccountingCode.find("b7c23e58-e44e-46ae-a3ec-b5081d6eed32")
        if bh["receivable_accounting_code_id"] != nil
        
          accounting_code = AccountingCode.find(bh["receivable_accounting_code_id"])
          accounting_code_interest = AccountingCode.find(bh["interest_receivable_accounting_code_id"])
          if bh["receivable_amount"] > 0
            #for principal
            journal_entries << {
              accounting_code_id: accounting_code.id,
              code: accounting_code.code,
              name: accounting_code.name,
              amount: bh["receivable_amount"]
            }
          end
            #for interest

          if bh["interest_receivable_amount"] > 0
            journal_entries << {
              accounting_code_id: accounting_code_interest.id,
              code: accounting_code_interest.code,
              name: accounting_code_interest.name,
              amount: bh["interest_receivable_amount"]
            }
          end
         

        end
        
      end

      journal_entries
  
    end
    def build_credit_journal_entries! #debit
      journal_entries = []
      accounting_code_wp = AccountingCode.find("b7c23e58-e44e-46ae-a3ec-b5081d6eed32")
      branch_accounting_code_id = Settings.branch_accounting_codes.select{ |o| o["branch_id"] == @branch.id }.first["cash_in_bank_accounting_code_id"]
      accounting_code = AccountingCode.find(branch_accounting_code_id)
      total_principal = @full_payment_billing.meta["header"][0].map{ |o| o["receivable_amount"] }.sum
      total_interest = @full_payment_billing.meta["header"][0].map{ |o| o["interest_receivable_amount"] }.sum
      total_wp = @full_payment_billing.meta["header"][0].select{ |o| o["loan_product"] == "WP" }.last["amount"]
      


      gtotal_amount = (total_principal.to_f + total_interest.to_f)  - total_wp.to_f
      if gtotal_amount > 0
        journal_entries << {
          accounting_code_id: accounting_code.id,
          code: accounting_code.code,
          name: accounting_code.name,
          amount: gtotal_amount.to_f 
        }
      end

          
            journal_entries << {
              accounting_code_id: accounting_code_wp.id,
              code: accounting_code_wp.code,
              name: accounting_code_wp.name,
              amount: total_wp
            }
        
      journal_entries
        
      
    end

    def default_particular
      "Payment of Loan"
    end


  end
end
