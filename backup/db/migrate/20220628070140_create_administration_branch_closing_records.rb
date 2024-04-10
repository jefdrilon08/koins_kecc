class CreateAdministrationBranchClosingRecords < ActiveRecord::Migration[7.0]
  def change
    create_table :administration_branch_closing_records, id: :uuid do |t|
      t.references :data_store, null: false, foreign_key: true, type: :uuid
      t.string :record_type
      t.jsonb :data
      t.date :closing_date
      t.references :branch, null: false, foreign_key: true, type: :uuid

      t.timestamps
    end
  end
end
