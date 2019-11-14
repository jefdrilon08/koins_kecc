class AddIndexForAccountTransactionsOnLoanPayments < ActiveRecord::Migration[5.2]
  def change
    #CREATE INDEX testindex ON account_transactions (transacted_at, subsidiary_id) WHERE transaction_type = 'loan_payment' AND subsidiary_type = 'Loan' AND amount > 0;
    add_index(
      :account_transactions, 
      [:transacted_at, :subsidiary_id], 
      name: 'index_account_transactions_loan_payments', 
      where: "(transaction_type = 'loan_payment' AND subsidiary_type = 'Loan' AND amount > 0)"
    )
  end
end
