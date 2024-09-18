module Adjustments
module MakePayments
  class BuildAccountingEntryForMakePayments
    
    def initialize(make_payment_data:, current_user:)
    
      @user =  current_user
      @make_payment_data = make_payment_data
      
      @book = @make_payment_data.meta["book"]



    

      @prepared_by  = @user.try(:full_name)
      @particular   = @make_payment_data.meta["particular"]
      @or_number    = @make_payment_data.meta["or_number"]
      @ar_number    = @make_payment_data.meta["ar_number"]
      @si_number    = @make_payment_data.meta["si_number"]
      @branch = Branch.find(Member.find(@make_payment_data["member_id"]).branch_id) 
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
          si_number: @si_number,
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
          post_type: "CR",
          accounting_code_id: j[:accounting_code_id],
          accounting_code_name: j[:name],
          amount: j[:amount]
        }
      end
      @accounting_entry_data[:debit_journal_entries].each do |j|
        @accounting_entry_data[:journal_entries] << {
          id: "",
          post_type: "DR",
          accounting_code_id: j[:accounting_code_id],
          accounting_code_name: j[:name],
          amount: j[:amount]
        }
      end

      @accounting_entry_data
  
    
      
    end

    private

    def build_credit_journal_entries! #credit
      journal_entries = []
      @make_payment_data[:data].each do |mpdr|
        #raise mpdr.inspect
        accounting_code_id = Settings.loan_product_accounting_codes.select{ |l| l[:loan_product_id] == Loan.find(mpdr["loan_id"]).loan_product_id  }.last.receivable_accounting_code_id   
        accounting_code = AccountingCode.find(accounting_code_id)
        journal_entries << {
          accounting_code_id: accounting_code.id,
          code: accounting_code.code,
          name: accounting_code.name,
          amount: mpdr["total_principal_balance"]
        }
      
         

      end

      journal_entries
  
    end

    def build_debit_journal_entries! #debit
      journal_entries = []
      member_type_details = Member.find(@make_payment_data["member_id"]).member_type
      total_principal_amount = @make_payment_data[:data].sum{ |m| m["total_principal_balance"]}

        if  member_type_details == "GK"
          accounting_code = AccountingCode.find("22f6ac03-ab97-4472-ad41-9a894a672e30")
        else
          accounting_code = AccountingCode.find(Settings.branch_accounting_codes.select{ |b| b[:branch_id] == @branch.id  }.last.cash_in_bank_accounting_code_id)
        end

        journal_entries << {
          accounting_code_id: accounting_code.id,
          code: accounting_code.code,
          name: accounting_code.name,
          amount: total_principal_amount
        }
      
         

      #end

      journal_entries
  
    end

  end
end
end
