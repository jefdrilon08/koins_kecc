class CreateMemberAccountDailyStatements < ActiveRecord::Migration[6.1]
  def change
    create_table :member_account_daily_statements, id: :uuid do |t|
      t.references :member, null: false, foreign_key: true, type: :uuid
      t.references :member_account, null: false, foreign_key: true, type: :uuid
      t.date :transacted_at
      t.references :branch, null: false, foreign_key: true, type: :uuid
      t.decimal :debit_amount
      t.decimal :credit_amount

      t.timestamps
    end

    add_index(
      :member_account_daily_statements,
      [:member_id, :member_account_id, :branch_id, :transacted_at],
      name: 'idx_macds_m_ma_b_t'
    )
  end
end
