module Members
  class BuildAccountingEntryForMakePayments
    
    def initialize(make_payment_data:, current_user:)
    
      @user =  current_user
      @make_payment_data = make_payment_data
      @book         = "CRB"
      @prepared_by  = @user.full_name
      @particular   = "sample"
      @or_number    = "0001"
      @branch = Branch.find(Member.find(@make_payment_data[:member_id]).branch_id) 
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
          ar_number: 0.0,
        }
      }
      
      
    end
    def execute!
      #raise build_credit_journal_entries!.inspect
      #@accounting_entry_data[:credit_journal_entries]  = build_credit_journal_entries!
      @accounting_entry_data[:debit_journal_entries]  = build_debit_journal_entries!
      #build journal entries
      #@accounting_entry_data[:credit_journal_entries].each do |j|
      #  @accounting_entry_data[:journal_entries] << {
      #    id: "",
      #    post_type: "DR",
      #    accounting_code_id: j[:accounting_code_id],
      #    accounting_code_name: j[:name],
      #    amount: j[:amount]
      #  }
      #end
      #@accounting_entry_data[:debit_journal_entries].each do |j|
      #  @accounting_entry_data[:journal_entries] << {
      #    id: "",
      #    post_type: "CR",
      #    accounting_code_id: j[:accounting_code_id],
      #    accounting_code_name: j[:name],
      #    amount: j[:amount]
      #  }
      #end
      
      #@accounting_entry_data
      
    end

    private

    def build_credit_journal_entries! #credit
      journal_entries = []
      @make_payment_data[:records].each do |mpdr|
        accounting_code_id = Settings.loan_product_accounting_codes.select{ |l| l[:loan_product_id] == Loan.find(mpdr[:loan_id]).loan_product_id  }.last.receivable_accounting_code_id   
        accounting_code = AccountingCode.find(accounting_code_id)
        journal_entries << {
          accounting_code_id: accounting_code.id,
          code: accounting_code.code,
          name: accounting_code.name,
          amount: mpdr[:total_principal_balance]
        }
      
         

      end

      journal_entries
  
    end

    def build_debit_journal_entries! #debit
      journal_entries = []
      member_type_details = Member.find(@make_payment_data[:member_id]).member_type
      #@make_payment_data[:records].each do |mpdr|
        if  member_type_details == "GK"
          accounting_code = AccountingCode.find("22f6ac03-ab97-4472-ad41-9a894a672e30")
        else
          accounting_code = AccountingCode.find("af83062d-628a-4fdd-acfd-bdebe2696513")
        end

        journal_entries << {
          accounting_code_id: accounting_code.id,
          code: accounting_code.code,
          name: accounting_code.name,
          amount: 100.0
        }
      
         

      #end

      raise journal_entries.inspect
  
    end

  end
end
