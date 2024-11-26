class CreateHolidays < ActiveRecord::Migration[7.1]
  def change
    create_table :holidays, id: :uuid do |t|
      t.string :holiday_name
      t.string :holiday_date
      t.string :status

      t.timestamps
    end
  end
end
