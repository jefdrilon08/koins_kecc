class CreateAccountingFunds < ActiveRecord::Migration[5.2]
  def change
    create_table :accounting_funds, id: :uuid do |t|
      t.string :name

      t.timestamps
    end
  end
end
