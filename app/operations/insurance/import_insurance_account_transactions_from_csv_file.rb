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
        uuid = row['id']
        insurance_account_transaction = AccountTransaction.where(id: uuid).first

        if insurance_account_transaction.nil?
          insurance_account_transaction = AccountTransaction.new

          insurance_account_transaction_data = JSON.parse(row['data'])

          insurance_account_transaction.id = uuid
          insurance_account_transaction.subsidiary_id = row['subsidiary_id']
          insurance_account_transaction.subsidiary_type = row['subsidiary_type']
          insurance_account_transaction.amount = row['amount']
          insurance_account_transaction.transaction_type = row['transaction_type']
          insurance_account_transaction.transacted_at = row['transacted_at']
          insurance_account_transaction.status = row['status']
          insurance_account_transaction.data = insurance_account_transaction_data
          insurance_account_transaction.created_at = row['created_at']
          insurance_account_transaction.updated_at = row['updated_at']

          insurance_account_transaction.save!

          insurance_account_ids << row['subsidiary_id']
        else
          insurance_account_transaction_data = JSON.parse(row['data'])

          insurance_account_transaction.update!(
            subsidiary_id: insurance_account_transaction.subsidiary_id,
            subsidiary_type: row['subsidiary_type'],
            amount: row['amount'],
            transaction_type: row['transaction_type'],
            transacted_at: row['transacted_at'],
            status: row['status'],
            data: insurance_account_transaction_data,
            created_at: row['created_at'],
            updated_at: row['updated_at']
          )

          insurance_account_ids << insurance_account_transaction.subsidiary_id
        end
      end

      # insurance_account_ids = insurance_account_ids.uniq

      # account_transactions = AccountTransaction.savings.where("amount > 0 AND subsidiary_id IN (?) AND status = ?", insurance_account_ids, "approved")

      # MemberAccount.where(id: insurance_account_ids, account_type: "INSURANCE").each do |member_account|
      #   ::MemberAccounts::Rehash.new(member_account: member_account, account_transactions: account_transactions).execute!
      # end
    end
  end
end
