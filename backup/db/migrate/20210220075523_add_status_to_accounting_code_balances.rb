class AddStatusToAccountingCodeBalances < ActiveRecord::Migration[6.1]
  def change
    add_column :accounting_code_balances, :status, :string
  end
end
