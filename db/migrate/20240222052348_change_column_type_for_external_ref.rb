class ChangeColumnTypeForExternalRef < ActiveRecord::Migration[7.0]
  def change
    change_column(:account_transactions, :external_ref, :string)
  end
end
