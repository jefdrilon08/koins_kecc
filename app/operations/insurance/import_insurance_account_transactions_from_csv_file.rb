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
        insurance_account_transaction_record = AccountTransaction.where(uuid: uuid).first

        if insurance_account_transaction_record.nil?
          insurance_account_transaction = AccountTransaction.new
          
          amount = row['amount']
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
          insurance_account = MerberAccount.where("uuid = ? AND status IN (?)", insurance_account_uuid, statuses).first
          # insurance_account = InsuranceAccount.where("uuid = ? AND status = ?", insurance_account_uuid, "active").first

          insurance_account_transaction.insurance_account_id = insurance_account.id
          transaction_type = row['transaction_type']
          insurance_account_transaction.amount = amount
          insurance_account_transaction.transaction_type = transaction_type
          
          insurance_account_transaction.save!
          
          insurance_account_ids << insurance_account_transaction.insurance_account.id
        else
          insurance_account_transaction_record.update!(
            amount: row['amount'],
            transaction_type: row['transaction_type'],
            transacted_at: row['transacted_at'],
            particular: row['particular'],
            status: row['status'],
            transacted_by: row['transacted_by'],
            approved_by: row['approved_by'],
            voucher_reference_number: row['voucher_reference_number'],
            transaction_number: row['transaction_number'],
            uuid: row['uuid'],
            transaction_date: row['transaction_date'],
            is_adjustment: row['is_adjustment']
          )

          insurance_account_ids << insurance_account_transaction_record.insurance_account.id
        end
      end

      insurance_account_ids = insurance_account_ids.uniq

      InsuranceAccount.where(id: insurance_account_ids).each do |acc|
        ::Insurance::RehashAccount.new(insurance_account: acc).execute!
      end
    end
  end
end
