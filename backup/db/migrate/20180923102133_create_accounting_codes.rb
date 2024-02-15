class CreateAccountingCodes < ActiveRecord::Migration[5.2]
  def change
    create_table :accounting_codes, id: :uuid do |t|
      t.string :name
      t.string :code
      t.string :category
      t.json :data

      t.timestamps
    end
  end
end
