class CreateMemberAccounts < ActiveRecord::Migration[5.2]
  def change
    create_table :member_accounts, id: :uuid do |t|
      t.references :member, type: :uuid, foreign_key: true
      t.string :account_type
      t.string :account_subtype
      t.decimal :balance
      t.references :center, type: :uuid, foreign_key: true
      t.references :branch, type: :uuid, foreign_key: true
      t.string :status
      t.decimal :maintaining_balance

      t.timestamps
    end
  end
end
