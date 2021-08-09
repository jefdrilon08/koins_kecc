module Insurance
  class LoadClipFromCsvFile
    def initialize(file:, user:)
      @file   = file
      @user   = user
    end

    def execute!
      load_csv_file!
    end

    private

    def load_csv_file!
      CSV.foreach(@file.path, headers: true) do |row|
        identification_number = row['identification_number']
        
        member = Member.where(identification_number: identification_number).first
        clip_account = member.member_accounts.where(account_subtype: "Credit Life Insurance Plan").first  

        loan_product_name = row['loan_product_name'] 
        date_released = row['date_released']
        amount = row['amount'].to_f

        account_transaction = AccountTransaction.where("subsidiary_id = ? AND amount = ? AND data->'data'->>'loan_product_name' = ? AND data->'data'->>'date_released' = ?", clip_account.id, amount, loan_product_name, date_released).first 
        
        if account_transaction.nil?
          clip_account_transaction = AccountTransaction.new

          clip_account_transaction.subsidiary_id = clip_account.id
          clip_account_transaction.subsidiary_type = "MemberAccount"
          clip_account_transaction.amount = amount
          clip_account_transaction.transaction_type = "deposit"
          clip_account_transaction.transacted_at = date_released
          clip_account_transaction.data  = {
                                            is_withdraw_payment: false,
                                            is_fund_transfer: false,
                                            is_interest: false,
                                            is_adjustment: false,
                                            is_for_exit_age: false,
                                            is_for_loan_payments: false,
                                            is_time_deposit: false,
                                            accounting_entry_reference_number: nil,
                                            beginning_balance: 0.00,
                                            ending_balance: 0.00,
                                            lock_in_period: nil,
                                            data: {
                                                id: row['id'],
                                                principal: row['principal'],
                                                interest: nil,
                                                first_date_of_payment: date_released,
                                                maturity_date: row['maturity_date'],
                                                original_maturity_date: nil,
                                                accounting_entry_id: nil,
                                                journal_entry_id: nil,
                                                amount: amount,
                                                loan_product_id: nil,
                                                loan_product_name: row['loan_product_name'],
                                                member_id: member.id,
                                                date_approved: date_released,
                                                date_released: date_released,
                                                reference_number: nil,
                                                book: nil,
                                                member_account_id: clip_account.id,
                                                term: "weekly",
                                                num_installments: row['num_installments'],
                                                account_transaction_id: nil,
                                                status: nil
                                              }
                                            }
          clip_account_transaction.save!
        end
      end
    end
  end
end
