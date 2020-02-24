module Insurance
  class   ImportInsuranceAccountTransactionsFromCsvFile
    def initialize(file:)
      @file = file
    end

    def execute!
      load_csv_file!
    end

    private

    def new_load_csv_file!
      uuids = []

      CSV.foreach(@file, headers: true) do |row|
        uuids << row['uuid']
      end

      uuids_for_updating  = AccountTransaction.where(id: uuids).pluck(:id)
    end

    def load_csv_file!
      insurance_account_ids = []

      CSV.foreach(@file, headers: true) do |row|
        uuid = row['uuid']
        insurance_account_transaction_record = AccountTransaction.where(id: uuid).first

        t_transaction_type    = row['transaction_type']
        t_is_withdraw_payment = false
        t_is_interest         = false
        t_is_fund_transfer    = false

        if t_transaction_type == "wp"
          t_transaction_type    = "withdraw"
          t_is_withdraw_payment = true
        elsif t_transaction_type == "interest"
          t_transaction_type  = "deposit"
          t_is_interest       = true
        elsif t_transaction_type == "reverse_deposit"
          t_transaction_type  = "withdraw"
        elsif t_transaction_type == "reverse_withdraw"
          t_transaction_type  = "deposit"
        elsif t_transaction_type == "fund_transfer_deposit"
          t_transaction_type  = "deposit"
          t_is_fund_transfer  = true
        end

        if insurance_account_transaction_record.nil?
          insurance_account_transaction = AccountTransaction.new

          insurance_account_transaction.id = uuid
          insurance_account_transaction.transacted_at = row['transacted_at']
          insurance_account_transaction.status = row['status']
          
          # data
          insurance_account_transaction.data = {
                                                is_withdraw_payment: t_is_withdraw_payment,
                                                is_fund_transfer: t_is_fund_transfer,
                                                is_interest: t_is_interest,
                                                is_adjustment: row['is_adjustment'],
                                                is_for_exit_age: row['for_exit_age'],
                                                is_for_loan_payments: row['for_loan_payments'],
                                                accounting_entry_reference_number: row['voucher_reference_number'],
                                                accounting_entry_particular: row['particular'],
                                                beginning_balance: row['beginning_balance'],
                                                ending_balance: row['ending_balance'],
                                                data: {
                                                  id: row['id_data'],
                                                  principal: row['principal_data'],
                                                  interest: row['interest'],
                                                  first_date_of_payment: row['first_date_of_payment_data'],
                                                  maturity_date: row['maturity_date_data'],
                                                  original_maturity_date: row['original_maturity_date_data'],
                                                  accounting_entry_id: row['accounting_entry_id_data'],
                                                  journal_entry_id: row['journal_entry_id_data'],
                                                  amount: row['amount_data'],
                                                  loan_product_id: row['loan_product_id_data'],
                                                  loan_product_name: row['loan_product_name_data'],
                                                  member_id: row['member_id_data'],
                                                  date_approved: row['date_approved_data'],
                                                  date_released: row['date_released_data'],
                                                  reference_number: row['reference_number_data'],
                                                  book: row['book_data'],
                                                  member_account_id: row['member_account_id_data'],
                                                  term: row['term_data'],
                                                  num_installments: row['num_installments_data'],
                                                  account_transaction_id: row['account_transaction_id_data'],
                                                  status: row['status_data']
                                                  }
                                                }
        
          statuses = ["active", "inactive"]
          insurance_account = MemberAccount.where("id = ? AND status IN (?)", row['insurance_account_uuid'], statuses).first
         
          insurance_account_transaction.subsidiary_id = insurance_account.id
          insurance_account_transaction.subsidiary_type = "MemberAccount"
          insurance_account_transaction.transaction_type = t_transaction_type
          insurance_account_transaction.amount = row['amount']
          
          insurance_account_transaction.save!
          
          insurance_account_ids << insurance_account_transaction.subsidiary_id
        else
          insurance_account_transaction_record_data = insurance_account_transaction_record.data.with_indifferent_access

          insurance_account_transaction_record_data[:is_withdraw_payment] = t_is_withdraw_payment
          insurance_account_transaction_record_data[:is_fund_transfer] = t_is_fund_transfer
          insurance_account_transaction_record_data[:is_interest] = t_is_interest
          insurance_account_transaction_record_data[:is_adjustment] = row['is_adjustment']
          insurance_account_transaction_record_data[:is_for_exit_age] = row['for_exit_age']
          insurance_account_transaction_record_data[:is_for_loan_payments] = row['for_loan_payments']
          insurance_account_transaction_record_data[:accounting_entry_reference_number] = row['voucher_reference_number']
          insurance_account_transaction_record_data[:accounting_entry_particular] = row['particular']
          insurance_account_transaction_record_data[:beginning_balance] = row['beginning_balance']
          insurance_account_transaction_record_data[:ending_balance] = row['ending_balance']
          
          if !insurance_account_transaction_record_data[:data].nil? 
            insurance_account_transaction_record_data[:data][:id] = row['id_data']
            insurance_account_transaction_record_data[:data][:principal] = row['principal_data']
            insurance_account_transaction_record_data[:data][:interest] = row['interest_data']
            insurance_account_transaction_record_data[:data][:first_date_of_payment] = row['first_date_of_payment_data']
            insurance_account_transaction_record_data[:data][:maturity_date] = row['maturity_date_data']
            insurance_account_transaction_record_data[:data][:original_maturity_date] = row['original_maturity_date_data']
            insurance_account_transaction_record_data[:data][:accounting_entry_id] = row['accounting_entry_id_data']
            insurance_account_transaction_record_data[:data][:journal_entry_id] = row['journal_entry_id_data']
            insurance_account_transaction_record_data[:data][:amount] = row['amount_data']
            insurance_account_transaction_record_data[:data][:loan_product_id] = row['loan_product_id_data']
            insurance_account_transaction_record_data[:data][:loan_product_name] = row['loan_product_name_data']
            insurance_account_transaction_record_data[:data][:member_id] = row['member_id_data']
            insurance_account_transaction_record_data[:data][:date_approved] = row['date_approved_data']
            insurance_account_transaction_record_data[:data][:date_released] = row['date_released_data']
            insurance_account_transaction_record_data[:data][:reference_number] = row['reference_number_data']
            insurance_account_transaction_record_data[:data][:book] = row['book_data']
            insurance_account_transaction_record_data[:data][:member_account_id] = row['member_account_id_data']
            insurance_account_transaction_record_data[:data][:term] = row['term_data']
            insurance_account_transaction_record_data[:data][:num_installments] = row['num_installments_data']
            insurance_account_transaction_record_data[:data][:account_transaction_id] = row['account_transaction_id_data']
            insurance_account_transaction_record_data[:data][:status] = row['status_data']
          else
            insurance_account_transaction_record_data[:data] = {
              id: row['id_data'],
              principal: row['principal_data'],
              interest: row['interest_data'],
              first_date_of_payment: row['first_date_of_payment_data'],
              maturity_date: row['maturity_date_data'],
              original_maturity_date: row['original_maturity_date_data'],
              accounting_entry_id: row['accounting_entry_id_data'],
              journal_entry_id: row['journal_entry_id_data'],
              amount: row['amount_data'],
              loan_product_id: row['loan_product_id_data'],
              loan_product_name: row['loan_product_name_data'],
              member_id: row['member_id_data'],
              date_approved: row['date_approved_data'],
              date_released: row['date_released_data'],
              reference_number: row['reference_number_data'],
              book: row['book_data'],
              member_account_id: row['member_account_id_data'],
              term: row['term_data'],
              num_installments: row['num_installments_data'],
              account_transaction_id: row['account_transaction_id_data'],
              status: row['status_data']
            }
          end

          insurance_account_transaction_record.update!(
            amount: row['amount'],
            subsidiary_id: row['insurance_account_uuid'],
            transaction_type: t_transaction_type,
            transacted_at: row['transacted_at'],
            status: row['status'],
            data: insurance_account_transaction_record_data
          )

          insurance_account_ids << insurance_account_transaction_record.subsidiary_id
        end
      end

      insurance_account_ids = insurance_account_ids.uniq

      account_transactions = AccountTransaction.savings.where("amount > 0 AND subsidiary_id IN (?) AND status = ?", insurance_account_ids, "approved")

      MemberAccount.where(id: insurance_account_ids, account_type: "INSURANCE").each do |member_account|
        ::MemberAccounts::Rehash.new(member_account: member_account, account_transactions: account_transactions).execute!
      end
    end
  end
end
