module AdditionalShare
  class Create
  
    def initialize(config: )
      @config           = config
      @branch           = @config[:branch]
      @center           = @config[:center]
      @transaction_date = Date.today
      @data_store_type  = "ADDITIONAL_SHARE"
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
              particular: "TO RECORD TRANSFER OF CBU, PSA & RSA FOR PAYMENT OF ADDITIONAL SHARE CAPITAL OF #{@center.name}",
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
        name: "PERSONAL SAVINGS",
        accounting_code_id: 'ba2c06dc-749a-4ca3-b09c-950669385126',
        total_amount: 0.0
      }
      @data_store.data['header'] << {
        name: "REGULAR SAVINGS",
        accounting_code_id: 'b7c23e58-e44e-46ae-a3ec-b5081d6eed32',
        total_amount: 0.0
      }
      @data_store.data['header'] << {
        name: "ADDITIONAL SHARE CAP",
        accounting_code_id: '370f5e4f-e4c8-454e-90b2-17919cc5ef92',
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
