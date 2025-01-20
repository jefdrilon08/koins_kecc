module Loans
  class BuildAccountingEntryForFullPayment
    def initialize(loan:, current_user:)
      @loan = loan
      #@loan_data = loan.data.with_indifferent_access
      
      @for_debit =  AccountingCode.find(Settings.branch_accounting_codes.select{ |o| o["branch_id"] == @loan.branch_id }.first["cash_in_bank_accounting_code_id"])
      @loan_product_accounting_codes  = Settings.loan_product_accounting_codes

      @book         = "JVB"
      @current_date = ::Utils::GetCurrentDate.new(
                        config: {
                          branch: @branch
                        }
                      ).execute!
      @prepared_by = current_user.full_name
      
      #@particular = "To cancel loan liquidation of jerrrss #{@loan.member.full_name }, CD REF# #{@loan_data[:accounting_entry][:reference_number]} .- #{@loan.branch.name}"
      @particular = "Payment of Loan / Deposit of Funds #{@loan.member.full_name }, #{@loan.branch.name}"



      @accounting_entry_data  = {
        book: @book,
        date_prepared: @current_date.strftime("%B %d, %Y"),
        company_name: Settings.company_name,
        company_address: Settings.company_address,
        branch: @loan.branch.name,
        prepared_by: @prepared_by,
        particular: @particular,
        debit_journal_entries: [],
        credit_journal_entries: [],
        journal_entries: [],
        branch_id: @loan.branch.id,
        branch_name: @loan.branch.name,
        status: "display",
        data: {
          or_number: "" ,
          ar_number: "",
        }
      }

    
    
    end
    def execute!
      @accounting_entry_data[:debit_journal_entries] = build_debit_journal_entries!
      @accounting_entry_data[:credit_journal_entries] = build_credit_journal_entries!
    
      @accounting_entry_data[:credit_journal_entries].each do |j|
        @accounting_entry_data[:journal_entries] << {
          id: "",
          post_type: "CR",
          accounting_code_id: j[:accounting_code_id],
          accounting_code_name: j[:name],
          amount: j[:amount].to_f
        }
      end


      #Raise @accounting_entry_data[:journal_entries].inspect

      @accounting_entry_data[:debit_journal_entries].each do |j|
        @accounting_entry_data[:journal_entries] << {
          id: "",
          post_type: "DR",
          accounting_code_id: j[:accounting_code_id],
          accounting_code_name: j[:name],
          amount: j[:amount].to_f
        }
      end
      
      @accounting_entry_data
    
    end


    private

    def build_debit_journal_entries! #debit
      journal_entries = []    
      journal_entries << {
        accounting_code_id: @for_debit.id,
        code: @for_debit.code,
        name: @for_debit.name,
        amount: @loan.principal_balance.to_f + @loan.interest_balance
      }
    
      
      journal_entries

    end
    def build_credit_journal_entries! #debi
      journal_entries = []
      @loan_product_accounting_codes.each do |o|
        if @loan.loan_product_id == o.loan_product_id 
            receivable_ac = ReadOnlyAccountingCode.where(id: o.receivable_accounting_code_id).first
            interest_ac   = ReadOnlyAccountingCode.where(id: o.interest_receivable_accounting_code_id).first
            if receivable_ac.blank?
              raise "#{o.receivable_accounting_code_id} not found. #{o.inspect}"
            end

            if interest_ac.blank?
              raise "#{o.interest_receivable_accounting_code_id} not found. #{o.inspect}"
            end
          
            journal_entries << {
              accounting_code_id: receivable_ac.id,
              code: receivable_ac.code,
              name: receivable_ac.name,
              record_type: "LOAN_PAYMENT",
              loan_product_id: @loan.loan_product_id ,
              receivable: true,
              interest: false,
              amount: @loan.principal_balance.to_f
            }

            journal_entries << {
              accounting_code_id: interest_ac.id,
              code: interest_ac.code,
              name: interest_ac.name,
              record_type: "LOAN_PAYMENT",
              loan_product_id: @loan.loan_product_id ,
              receivable: false,
              interest: true,
              amount: @loan.interest_balance
            }
        
        end

      end
      
      journal_entries
    end

    end
end
