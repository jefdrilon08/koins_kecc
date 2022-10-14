class CreateDwBranchLoanProductActiveLoanCounts < ActiveRecord::Migration[6.1]
  def change
    create_table :dw_branch_loan_product_active_loan_counts, id: :uuid do |t|
      t.references :branch, null: false, foreign_key: true, type: :uuid, index: { name: 'dw_b_lp_alc_index' }
      t.references :cluster, null: false, foreign_key: true, type: :uuid, index: { name: 'dw_c_lp_alc_index' }
      t.references :area, null: false, foreign_key: true, type: :uuid, index: { name: 'dw_a_lp_alc_index' }
      t.string :status
      t.date :as_of
      t.jsonb :data
      t.integer :total
      t.references :loan_product, null: false, foreign_key: true, type: :uuid, index: { name: 'dw_lp_alc_index' }
      t.references :loan_product_category, null: false, foreign_key: true, type: :uuid, index: { name: 'dw_lpc_alc_index' }

      t.timestamps
    end
  end
end
