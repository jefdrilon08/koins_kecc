module MbsTransfer
  class Create
  
    def initialize(config: )
      @config           = config
      @branch           = @config[:branch]
      @center           = @config[:center]
      @transaction_date = Date.today
      @data_store_type  = "MBS_TRANSFER"
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
              particular: "TO RECORD TRANSFER OF CBU & RSA FOR MBS OF #{@center.name}",
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
          record: [],
          total_cash_payment: 0.0,
          total_payment: 0.0
        },
        status: "pending"
      )

    end
    def data_header!
      @data_store.data['header'] << {
        name: "CBU",
        accounting_code_id: '5091fee6-b2a2-40a0-a717-c53ab483ea43',
        total_amount: 0.0
      }
     @data_store.data['header'] << {
        name: "REGULAR SAVINGS",
        accounting_code_id: 'b7c23e58-e44e-46ae-a3ec-b5081d6eed32',
        total_amount: 0.0
      }
      @data_store.data['header'] << {
        name: "MBS",
        accounting_code_id: '1e849571-b1e3-49d8-af5d-2bcbb4b5c314',
        total_amount: 0.0
      }
    end

    def execute!
      data_header!
      @data_store.save!
      @data_store
    end
  
  end
end
