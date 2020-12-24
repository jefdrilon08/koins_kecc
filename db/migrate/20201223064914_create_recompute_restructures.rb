class CreateRecomputeRestructures < ActiveRecord::Migration[6.0]
  def change
    create_table :recompute_restructures, id: :uuid do |t|
      t.string :branch, null: false, foreign_key: true
      t.string :center, null: false, foreign_key: true
      t.string :status
      t.date :transaction_date
      t.json :data

      t.timestamps
    end
  end
end
