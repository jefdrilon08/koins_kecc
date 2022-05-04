module BillingForWriteoffCollection
  class Create
   
   def initialize(config: )
  
    @config           = config
    @branch           = @config[:branch]
    @center           = @config[:center]
    @transaction_date = Date.today
    @data_store_type  = "BILLING_FOR_WRITEOFF_COLLECTION"
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
        center_id: @center.id,
        center_name: @center.name,
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
          header: [],
          record: []
        },
        status: "pending"
      )
   end
   def process_data_header!
     @header = []
     @h_data = Loan.where(status: 'writeoff' , center_id: @center.id)
     @h_data.pluck(:loan_product_id).uniq.each do |hd|
      @header << LoanProduct.find(hd)
     end
     @header.uniq.each do |headers|
      @data_store.data['header'] << {
        name: headers.name
      }
     end
     @data_store.data['header'] << {
      name: "Withdraw Payment"
     }
   end
   def process_data_record!
     #member_data
     @h_data.joins(:member).order(:last_name).pluck(:member_id).uniq.each do |records|
      @data_store.data['record'] << {
        member_id: records,
        name:      Member.find(records).full_name,
        enabled:   false,
        loan_data: []
      }
     end

     #loan_data
     @data_store.data['record'].each do |loan_data|
      @header.each do |hld|
        l = Loan.where("member_id = ? and loan_product_id = ? and status = 'writeoff'" , loan_data[:member_id] , hld.id).last
        if l.present?
          loan_data[:loan_data] << {
            name: hld.name,
            loan_id: l.id,
            loan_product_id: l.loan_product_id,
            enabled: true,
            amount: 0.0
          }
        else
          loan_data[:loan_data] << {
            name: hld.name,
            loan_id: '',
            loan_product_id: nil,
            enabled: false,
            amount: nil
          }
        end 
      end
          loan_data[:loan_data] << {
            name: "Withdraw Payment",
            loan_id: '',
            loan_product_id: nil,
            enabled: true,
            amount: 0.0
          }

     end
   end
   def execute!
    process_data_header!
    process_data_record!
    @data_store.save!
    @data_store
   end
  end
end
