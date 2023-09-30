module BillingForInvoluntary
  class Create
    def initialize(config: )  
      @config           = config
      @branch           = @config[:branch]
      @transaction_date = Date.today
      @data_store_type  = "BILLING_FOR_INVOLUNTARY"
      @current_date     = ::Utils::GetCurrentDate.new(
                            config: {
                              branch: @branch
                            }
                          ).execute!

      @data_store = DataStore.create(
        meta: {
          data_store_type: @data_store_type,
          branch_id: @branch.id,
          branch_name: @branch.name,
          transaction_date: @current_date,
          date_approved: ""
        },
        data: {
          accounting_entry: {
            book: "JVB",
            reference_number: "",
            date_prepared: @transaction_date,
            company_name: Settings.company_name,
            branch: @branch.to_s.upcase,
            prepared_by: @user.to_s,
            particular: "to record collection for the Involuntary",
            debit_journal_entries: [],
            credit_journal_entries: [],
            journal_entries: [],
            branch_id: @branch.id,
            branch_name: @branch.name,
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
          
          records: [],
          total_loan: 0.0,
          total_savings: 0.0,
          total_equity: 0.0,
          total_accrued: 0.0
        },
        status: "pending"
      )
    end
   

   
    def execute!

      @data_store.save!
      @data_store
    end
      
  end
end
