module Loans
  class BuildAccountingEntryForReverse
    def initialize(loan:, current_user:)
      @loan = loan
      @loan_data = loan.data.with_indifferent_access
      @for_credit = @loan_data[:accounting_entry][:debit_journal_entries]
      @for_debit = @loan_data[:accounting_entry][:credit_journal_entries]
      @book         = "JVB"
      @current_date = ::Utils::GetCurrentDate.new(
                        config: {
                          branch: @branch
                        }
                      ).execute!
      @prepared_by = current_user.full_name
      
      @particular = "To cancel loan liquidation of #{@loan.member.full_name }, CD REF# #{@loan_data[:accounting_entry][:reference_number]} .- #{@loan.branch.name}"

      @accounting_entry_data  = {
        book: @book,
        date_prepared: @current_date.strftime("%B %d, %Y"),
        company_name: Settings.company_name,
        company_address: Settings.company_address,
        branch: loan.branch.name,
        prepared_by: @prepared_by,
        particular: @particular,
        debit_journal_entries: [],
        credit_journal_entries: [],
        journal_entries: [],
        branch_id: loan.branch.id,
        branch_name: loan.branch.name,
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

    def build_debit_journal_entries! #debit
      journal_entries = []
      @for_debit.each do |fd|
        
        journal_entries << {
          accounting_code_id: fd[:accounting_code_id],
          code: fd[:code],
          name: fd[:name],
          amount: fd[:amount]
        }
      end
      
      journal_entries

    end
    def build_credit_journal_entries! #debi
      journal_entries = []
      @for_credit.each do |fc|
        
        journal_entries << {
          accounting_code_id: fc[:accounting_code_id],
          code: fc[:code],
          name: fc[:name],
          amount: fc[:amount]
        }
      end
      
      journal_entries
    end

  end
end
