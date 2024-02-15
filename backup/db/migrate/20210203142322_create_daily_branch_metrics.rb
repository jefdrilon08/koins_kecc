class CreateDailyBranchMetrics < ActiveRecord::Migration[6.0]
  def change
    create_table :daily_branch_metrics, id: :uuid do |t|
      t.decimal :principal
      t.decimal :interest
      t.decimal :total
      t.decimal :principal_due
      t.decimal :interest_due
      t.decimal :total_due
      t.decimal :principal_paid
      t.decimal :interest_paid
      t.decimal :principal_paid_due
      t.decimal :portfolio
      t.decimal :interest_paid_due
      t.decimal :total_paid_due
      t.decimal :total_paid
      t.decimal :principal_balance
      t.decimal :interest_balance
      t.decimal :total_balance
      t.decimal :overall_principal_balance
      t.decimal :overall_interest_balance
      t.decimal :overall_balance
      t.decimal :principal_rr
      t.decimal :interest_rr
      t.decimal :total_rr
      t.decimal :par_amount
      t.decimal :par
      t.integer :num_days_par
      t.string :status

      t.date :as_of
      t.jsonb :data
      t.references :branch, null: false, foreign_key: true, type: :uuid
      t.references :cluster, null: false, foreign_key: true, type: :uuid
      t.references :area, null: false, foreign_key: true, type: :uuid

      t.timestamps
    end
  end
end
