module BillingForWriteoff
  class Create
   
   def initialize(config: )
  
    @config = config
    @branch = @config[:branch]
    @year   = @config[:year]
    @transaction_date = Date.today
    @data_store_type = "BILLING_FOR_WRITEOFF"
    
   end

   def execute!
    @data_store = DataStore.create(
      meta: {
        as_of: @year,
        data_store_type: @data_store_type,
        branch_id: @branch.id,
        branch_name: @branch.name,
        transaction_date: @transaction_date,
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
              particular: "",
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
          record: []
        },
        as_of: @year,
        status: "pending"
      )
    @data_store
   end
  

  end
end
