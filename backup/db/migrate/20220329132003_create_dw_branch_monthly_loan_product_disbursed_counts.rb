class CreateDwBranchMonthlyLoanProductDisbursedCounts < ActiveRecord::Migration[6.1]
  def change
    create_table :dw_branch_monthly_loan_product_disbursed_counts, id: :uuid do |t|
      t.references :branch, null: false, foreign_key: true, type: :uuid, index: { name: 'dw_b_m_lpdc_index' }
      t.references :area, null: false, foreign_key: true, type: :uuid, index: { name: 'dw_a_m_lpdc_index' }
      t.references :cluster, null: false, foreign_key: true, type: :uuid, index: { name: 'dw_c_m_lpdc_index' }
      t.references :loan_product, null: false, foreign_key: true, type: :uuid, index: { name: 'dw_lp_m_lpdc_index' }
      t.references :loan_product_category, null: false, foreign_key: true, type: :uuid, index: { name: 'dw_lpc_m_lpdc_index' }
      t.integer :month
      t.integer :year
      t.string :status
      t.integer :total
      t.jsonb :data

      t.timestamps
    end
  end
end
