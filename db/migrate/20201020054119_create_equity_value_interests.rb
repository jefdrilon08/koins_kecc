class CreateEquityValueInterests < ActiveRecord::Migration[6.0]
  def change
    create_table :equity_value_interests, id: :uuid do |t|
      t.references :member_account, type: :uuid, foreign_key: true
      t.references :account_transaction, type: :uuid, foreign_key: true
      t.date :month_of_year_date
      t.decimal :interest_amount

      t.timestamps
    end
  end
end
