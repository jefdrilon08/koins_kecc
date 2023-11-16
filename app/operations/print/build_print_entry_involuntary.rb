module Print
    class BuildPrintEntryInvoluntary
        include ActionView::Helpers::NumberHelper
        def initialize(config:)
            
            @data_store = DataStore.find(config)
            @datastore_data = @data_store.data.with_indifferent_access
            @data = {
                accounting_entry_transfer: {},
                accounting_entry_loans: {}
            }

            @data[:company_name]          = Settings.company_name
            @data[:company_address]       = Settings.company_address
            @data[:branch]          = @data_store.meta["branch_name"]
            @data[:prepared_by] = @data_store.meta["prepared_by"]["name"]

            
            
        end
        def execute!
            @data[:accounting_entry_transfer]["date_prepared"] = @datastore_data[:accounting_entry_transfer_savings]["date_prepared"]
            @data[:accounting_entry_transfer]["book"] = @datastore_data[:accounting_entry_transfer_savings]["book"]
            @data[:accounting_entry_transfer]["reference_number"] = @datastore_data[:accounting_entry_transfer_savings]["reference_number"]
            @data[:accounting_entry_transfer]["data"] = @datastore_data[:accounting_entry_transfer_savings]["data"]
            @data[:accounting_entry_transfer]["approved_by"]= @datastore_data[:accounting_entry_transfer_savings]["approved_by"]
            @data[:accounting_entry_transfer]["particular"] = @datastore_data[:accounting_entry_transfer_savings]["particular"]
            @data[:accounting_entry_transfer]["payee"] = @datastore_data[:accounting_entry_transfer_savings]["payee"]
            @data[:accounting_entry_transfer]["subreference_number"] = @datastore_data[:accounting_entry_transfer_savings]["subreference_number"]
            @data[:accounting_entry_transfer]["or_number"] = @datastore_data[:accounting_entry_transfer_savings]["or_number"]
            @data[:accounting_entry_transfer]["ar_number"] == @datastore_data[:accounting_entry_transfer_savings]["ar_number"]
            
            @data[:accounting_entry_transfer]["total_credit"] = 0.0
            @data[:accounting_entry_transfer]["total_debit"] = 0.0
            
            if @data_store[:meta]["date_approved"].present?
                @data[:accounting_entry_transfer]["date_posted"] = @data_store[:meta]["date_approved"]
            end
            @debit_amount = []
            @credit_amount = []
            @data[:accounting_entry_transfer]["debit_journal_entries"] = []

            @datastore_data[:accounting_entry_transfer_savings][:debit_journal_entries].each do |dr|
                @data[:accounting_entry_transfer]["debit_journal_entries"] << {
                    code: dr[:code],
                    name: dr[:name],
                    amount:number_to_currency(dr[:amount],unit: "")
                }
                @debit_amount << dr[:amount]
            end

            @data[:accounting_entry_transfer]["credit_journal_entries"]= []
            
            @datastore_data[:accounting_entry_transfer_savings][:credit_journal_entries].each do |cr|
                @data[:accounting_entry_transfer]["credit_journal_entries"] << {
                    code: cr[:code],
                    name: cr[:name],
                    amount: number_to_currency(cr[:amount],unit: "")
                }
                @credit_amount << cr[:amount]
            end

            @data[:accounting_entry_transfer]["total_debit"] = number_to_currency(@debit_amount.sum.round(2),unit: "")
            @data[:accounting_entry_transfer]["total_credit"] =number_to_currency(@credit_amount.sum.round(2),unit: "")


            #loans
            @data[:accounting_entry_loans]["date_prepared"] = @datastore_data[:accounting_entry_loan_payments]["date_prepared"]
            @data[:accounting_entry_loans]["book"]              = @datastore_data[:accounting_entry_loan_payments]["book"]
            @data[:accounting_entry_loans]["reference_number"] = @datastore_data[:accounting_entry_loan_payments]["reference_number"]
            @data[:accounting_entry_loans]["data"] = @datastore_data[:accounting_entry_loan_payments]["data"]
            @data[:accounting_entry_loans]["approved_by"]= @datastore_data[:accounting_entry_loan_payments]["approved_by"]
            @data[:accounting_entry_loans]["particular"] = @datastore_data[:accounting_entry_loan_payments]["particular"]
            @data[:accounting_entry_loans]["payee"] = @datastore_data[:accounting_entry_loan_payments]["payee"]
            @data[:accounting_entry_loans]["subreference_number"] = @datastore_data[:accounting_entry_loan_payments]["subreference_number"]
            @data[:accounting_entry_loans]["or_number"] = @datastore_data[:accounting_entry_loan_payments]["or_number"]
            @data[:accounting_entry_loans]["ar_number"] == @datastore_data[:accounting_entry_loan_payments]["ar_number"]
            
            @data[:accounting_entry_loans]["total_credit"] = 0.0
            @data[:accounting_entry_loans]["total_debit"] = 0.0
            
            if @data_store[:meta]["date_approved"].present?
                @data[:accounting_entry_loans]["date_posted"] = @data_store[:meta]["date_approved"]
            end
            @debit_amount = []
            @credit_amount = []
            @data[:accounting_entry_loans]["debit_journal_entries"] = []

            @datastore_data[:accounting_entry_loan_payments][:debit_journal_entries].each do |dr|
                @data[:accounting_entry_loans]["debit_journal_entries"] << {
                    code: dr[:code],
                    name: dr[:name],
                    amount:number_to_currency(dr[:amount],unit: "")
                }
                @debit_amount << dr[:amount]
            end

            @data[:accounting_entry_loans]["credit_journal_entries"]= []
            
            @datastore_data[:accounting_entry_loan_payments][:credit_journal_entries].each do |cr|
                @data[:accounting_entry_loans]["credit_journal_entries"] << {
                    code: cr[:code],
                    name: cr[:name],
                    amount: number_to_currency(cr[:amount],unit: "")
                }
                @credit_amount << cr[:amount]
            end

            @data[:accounting_entry_loans]["total_debit"] = number_to_currency(@debit_amount.sum.round(2),unit: "")
            @data[:accounting_entry_loans]["total_credit"] =number_to_currency(@credit_amount.sum.round(2),unit: "")

           @data
            
            
        end
    end
end