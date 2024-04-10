class CreateAccountingCodeBalances < ActiveRecord::Migration[6.1]
  def change
    create_table :accounting_code_balances, id: :uuid do |t|
      t.references :accounting_code, null: false, foreign_key: true, type: :uuid
      t.references :accounting_fund, foreign_key: true, type: :uuid
      t.references :branch, null: false, foreign_key: true, type: :uuid
      t.string :category
      t.date :start_date
      t.date :end_date
      t.decimal :total_beginning_debit
      t.decimal :total_beginning_credit
      t.decimal :total_current_debit
      t.decimal :total_current_credit
      t.decimal :total_ending_debit
      t.decimal :total_ending_credit

      t.timestamps
    end

    add_index(
      :accounting_code_balances,
      [:accounting_code_id, :category, :branch_id, :start_date, :end_date],
      name: 'idx_acb_ac_id_cat_branch_id_sd_ed'
    )
  end
end
