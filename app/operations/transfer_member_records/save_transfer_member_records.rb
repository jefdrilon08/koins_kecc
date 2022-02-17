module TransferMemberRecords
  class SaveTransferMemberRecords
    def initialize(config:)
      @config = config
      @from_branch    =Branch.find(@config[:branch_id])
      @to_branch      =Branch.find(@config[:branch_id_to_transfer])
      @transaction_date = ::Utils::GetCurrentDate.new(
                              config: {
                                branch: @branch
                              }
                            ).execute!
      
    end
    
    def execute!
      @transfer_member_records = TransferMemberRecord.create(
            branch_id: @from_branch.id,
            branch_id_to_transfer: @to_branch.id,
            transfer_date: @transaction_date,
            status: "pending",
            data: {
              accounting_entry_from: {
                book: "JVB",
                reference_number: "",
                date_prepared: @transaction_date,
                company_name: Settings.company_name,
                branch: @from_branch.to_s.upcase,
                prepared_by: @user.to_s,
                particular: nil,
                debit_journal_entries: [],
                credit_journal_entries: [],
                journal_entries: [],
                branch_id: @from_branch.id,
                branch_name: @from_branch.name,
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
              },
              accounting_entry_to: {
                book: "JVB",
                reference_number: "",
                date_prepared: @transaction_date,
                company_name: Settings.company_name,
                branch: @to_branch.to_s.upcase,
                prepared_by: @user.to_s,
                particular: nil,
                debit_journal_entries: [],
                credit_journal_entries: [],
                journal_entries: [],
                branch_id: @to_branch.id,
                branch_name: @to_branch.name,
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
              },
              records: []
            },
            date_approved: ""

        )
      @transfer_member_records
    
    end
  end
end
