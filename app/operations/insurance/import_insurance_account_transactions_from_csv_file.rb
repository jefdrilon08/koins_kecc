module Insurance
  class ImportInsuranceAccountTransactionsFromCsvFile
    def initialize(file:)
      @file = file
    end

    def execute!
      load_csv_file!
    end

    private

    def load_csv_file!
      insurance_account_ids = []

      CSV.foreach(@file, headers: true) do |row|
        uuid = row['uuid']
        insurance_account_transaction_record = AccountTransaction.where(id: uuid).first

        if insurance_account_transaction_record.nil?
          insurance_account_transaction = AccountTransaction.new

          insurance_account_transaction.id = uuid
          insurance_account_transaction.transacted_at = row['transacted_at']
          insurance_account_transaction.status = row['status']
          
          # data
          insurance_account_transaction.data = {
                                                is_withdraw_payment: false,
                                                is_fund_transfer: false,
                                                is_interest: false,
                                                is_adjustment: row['is_adjustment'],
                                                is_for_exit_age: row['for_exit_age'],
                                                is_for_loan_payments: row['for_loan_payments'],
                                                accounting_entry_reference_number: row['voucher_reference_number'],
                                                accounting_entry_particular: row['particular'],
                                                beginning_balance: row['beginning_balance'],
                                                ending_balance: row['ending_balance']
                                                }
        
          statuses = ["active", "inactive"]
          insurance_account = MemberAccount.where("id = ? AND status IN (?)", row['insurance_account_uuid'], statuses).first
         
          insurance_account_transaction.subsidiary_id = insurance_account.id
          insurance_account_transaction.subsidiary_type = "MemberAccount"
          insurance_account_transaction.transaction_type = row['transaction_type']
          insurance_account_transaction.amount = row['amount']
          
          insurance_account_transaction.save!
          
          insurance_account_ids << insurance_account_transaction.subsidiary_id
        else
          insurance_account_transaction_record_data = insurance_account_transaction_record.data.with_indifferent_access

          insurance_account_transaction_record_data[:is_withdraw_payment] = false
          insurance_account_transaction_record_data[:is_fund_transfer] = false
          insurance_account_transaction_record_data[:is_interest] = false
          insurance_account_transaction_record_data[:is_adjustment] = row['is_adjustment']
          insurance_account_transaction_record_data[:is_for_exit_age] = row['for_exit_age']
          insurance_account_transaction_record_data[:is_for_loan_payments] = row['for_loan_payments']
          insurance_account_transaction_record_data[:accounting_entry_reference_number] = row['voucher_reference_number']
          insurance_account_transaction_record_data[:accounting_entry_particular] = row['particular']
          insurance_account_transaction_record_data[:beginning_balance] = row['beginning_balance']
          insurance_account_transaction_record_data[:ending_balance] = row['ending_balance']

          insurance_account_transaction_record.update!(
            amount: row['amount'],
            subsidiary_id: row['insurance_account_uuid'],
            transaction_type: row['transaction_type'],
            transacted_at: row['transacted_at'],
            status: row['status'],
            data: insurance_account_transaction_record_data
          )

          insurance_account_ids << insurance_account_transaction_record.subsidiary_id
        end
      end

      insurance_account_ids = insurance_account_ids.uniq

      MemberAccount.where(id: insurance_account_ids).each do |acc|
        ::MemberAccounts::Rehash.new(member_account: acc).execute!
      end
    end
  end
end
