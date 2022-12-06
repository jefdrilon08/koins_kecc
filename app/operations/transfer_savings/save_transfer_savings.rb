module TransferSavings
  class SaveTransferSavings

    def initialize(config:)
      @config = config
      @branch = Branch.find(@config[:branch_id])
      @users  = @config[:user]
     
      @date = ::Utils::GetCurrentDate.new(
              config: {
                branch: @branch
                }
              ).execute!  

      

    end

    def execute!
      @transfer_savings_records = TransferSavingsRecord.new(
        branch_id: @branch.id,
        center_id: nil,
        status: "pending",
        data: {
          member_records: [],
          accounting_entry: 
            {
                book: "JVB",
                reference_number: "",
                date_prepared: @date,
                company_name: Settings.company_name,
                branch: @branch.name.to_s.upcase,
                prepared_by: @users.full_name,
                particular: nil,
                debit_journal_entries: [],
                credit_journal_entries: [],
                journal_entries: [],
                branch_id: @branch.id,
                branch_name: @branch.name.to_s.upcase,
                status: "display",
                data: {
                or_number: "",
                ar_number: "",
                check_number: "",
                check_voucher_number: "",
                date_of_check: "",
                sub_reference_number: "",
                payee: ""
            }
          }
        }
      )
      @transfer_savings_records.save!
      @transfer_savings_records
    end     
  end
end
