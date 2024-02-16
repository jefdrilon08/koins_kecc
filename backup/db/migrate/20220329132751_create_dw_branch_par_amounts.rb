class CreateDwBranchParAmounts < ActiveRecord::Migration[6.1]
  def change
    create_table :dw_branch_par_amounts, id: :uuid do |t|
      t.references :branch, null: false, foreign_key: true, type: :uuid
      t.references :area, null: false, foreign_key: true, type: :uuid
      t.references :cluster, null: false, foreign_key: true, type: :uuid
      t.decimal :amount
      t.jsonb :data
      t.string :record_type
      t.string :status
      t.integer :month
      t.integer :year

      t.timestamps
    end
  end
end
