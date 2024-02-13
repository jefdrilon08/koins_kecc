module BillingForInvoluntary
    class ValidateApprove < AppValidator
    def initialize(config:)
        super()
        @data_store = DataStore.find(config[:data_store_id])
        @data = @data_store.data.with_indifferent_access
        @current_user = User.find(config[:current_user])

        #entry
        @accounting_entry_transfer_savings  = @data[:accounting_entry_transfer_savings]
        @accounting_entry_loan_payments     = @data[:accounting_entry_loan_payments]

    end

    def execute!


        validate_accounting_entry!
        if @data_store.blank?
            @errors[:messages] << {
                key: "dataStore",
                message: "data cannot find"
              }
        end

        if @data_store.status != "pending"
            @errors[:messages] << {
                key: "dataStore",
                message: "collection status is #{@data_store.status}"
            }
        end

        if @current_user.blank?
            @errors[:messages] << {
                key: "User",
                message: "user cannot find"
            }
        end

        @errors[:messages].each do |o|
            @errors[:full_messages] << o[:message]
        end
        @errors


    end

    def validate_accounting_entry!

        @total_loan_payment_debit = 0.0
        @total_loan_payment_credit = 0.0

        if  @accounting_entry_transfer_savings[:credit_journal_entries].blank?
            @errors[:messages] << {
                key: "accounting_entry",
                message: "accounting entry transfer savings credit not balanced"
            }
            elsif @accounting_entry_transfer_savings[:debit_journal_entries].blank?
                @errors[:messages] << {
                    key: "accounting_entry",
                    message: "accounting entry transfer savings debit not balanced"
                }

        end
        if @accounting_entry_loan_payments[:debit_journal_entries].blank?
            @errors[:messages] << {
                key: "accounting_entry",
                message: "accounting entry loan payments not balanced"
            }
            elsif @accounting_entry_loan_payments[:credit_journal_entries].blank?
                @errors[:messages] << {
                    key: "accounting_entry",
                    message: "accounting entry loan payments credit not balanced"
                }
        end
        if @accounting_entry_loan_payments[:journal_entries].any?
            @accounting_entry_loan_payments[:journal_entries].each do |o|
            if o[:post_type] == "DR"
                @total_loan_payment_debit += o[:amount].to_f.round(2)
            end

            if o[:post_type] == "CR"
                @total_loan_payment_credit += o[:amount].to_f.round(2)
            end

        end
        total_loan_payment_debit = @total_loan_payment_debit.round(2)
        total_loan_payment_credit = @total_loan_payment_credit.round(2)

        if total_loan_payment_debit != total_loan_payment_credit
            @errors[:messages] << {
                key: "accounting_entry",
                message: "Accounting entry for payment not balanced. DR: #{total_loan_payment_debit} CR: #{total_loan_payment_credit}"
              }
        end
    end
    #raise @total_loan_payment_credit.inspect
    #raise @accounting_entry_loan_payments[:journal_entries].inspect
    #raise @accounting_entry_loan_payments[:credit_journal_entries][0][:amount].to_f.inspect
    #raise @accounting_entry_loan_payments[:credit_journal_entries][0][:amount].to_f.inspect
    end

    end
end
