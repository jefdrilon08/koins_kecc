class CreateBranchPsrRecords < ActiveRecord::Migration[7.0]
  def change
    create_table :branch_psr_records, id: :uuid do |t|
      t.references :branch, null: false, foreign_key: true, type: :uuid
      t.date :closing_date
      t.integer :closing_year
      t.integer :closing_month
      t.jsonb :data
      t.string :status

      t.timestamps
    end
  end
end
