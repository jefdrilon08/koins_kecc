class AddAccountingFundToAccountingEntries < ActiveRecord::Migration[5.2]
  def change
    add_reference :accounting_entries, :accounting_fund, foreign_key: true, type: :uuid
  end
end
