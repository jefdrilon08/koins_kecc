class CreateDwBranchActiveLoanCounts < ActiveRecord::Migration[6.1]
  def change
    create_table :dw_branch_active_loan_counts, id: :uuid do |t|
      t.references :branch, null: false, foreign_key: true, type: :uuid
      t.references :cluster, null: false, foreign_key: true, type: :uuid
      t.references :area, null: false, foreign_key: true, type: :uuid
      t.string :status
      t.date :as_of
      t.jsonb :data
      t.integer :total

      t.timestamps
    end
  end
end
