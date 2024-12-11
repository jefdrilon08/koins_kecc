class CreateHolidayRecords < ActiveRecord::Migration[7.1]
  def change
    create_table :holiday_records, id: :uuid do |t|
      t.string :holiday_name
      t.date :holiday_date
      t.string :status
      t.json :data

      t.timestamps
    end
  end
end
