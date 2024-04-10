class CreateDwBranchLoanProductOutstandingLoanAmounts < ActiveRecord::Migration[6.1]
  def change
    create_table :dw_branch_loan_product_outstanding_loan_amounts, id: :uuid do |t|
      t.references :branch, null: false, foreign_key: true, type: :uuid, index: { name: 'dw_b_lp_ola_index' }
      t.references :cluster, null: false, foreign_key: true, type: :uuid, index: { name: 'dw_b_lp_c_ola_index' }
      t.references :area, null: false, foreign_key: true, type: :uuid, index: { name: 'dw_b_lp_a_ola_index' }
      t.string :status
      t.jsonb :data
      t.decimal :amount
      t.references :loan_product_category, null: false, foreign_key: true, type: :uuid, index: { name: 'dw_b_lp_lpc_ola_index' }
      t.references :loan_product, null: false, foreign_key: true, type: :uuid, index: { name: 'dw_b_lp_lp_ola_index' }
      t.date :as_of

      t.timestamps
    end
  end
end
