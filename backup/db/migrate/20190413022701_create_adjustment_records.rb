class CreateAdjustmentRecords < ActiveRecord::Migration[5.2]
  def change
    create_table :adjustment_records, id: :uuid do |t|
      t.jsonb :meta
      t.jsonb :data
      t.string :status

      t.timestamps
    end
  end
end
