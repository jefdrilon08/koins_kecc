class CreateMonthlyAccountingCodeSummaries < ActiveRecord::Migration[6.1]
  def change
    create_table :monthly_accounting_code_summaries, id: :uuid do |t|
      t.integer :month
      t.integer :year
      t.references :branch, null: false, foreign_key: true, type: :uuid
      t.references :accounting_code, null: false, foreign_key: true, type: :uuid
      t.string :category
      t.string :name
      t.decimal :dr_amount
      t.decimal :cr_amount

      t.timestamps
    end

    add_index(
      :monthly_accounting_code_summaries,
      [:month, :year, :accounting_code_id, :branch_id],
      name: 'idx_macs_m_y_ac_id_b_id'
    )
  end
end
