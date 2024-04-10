class CreateAccruedInterests < ActiveRecord::Migration[6.0]
  def change
    create_table :accrued_interests, id: :uuid do |t|
      t.string :branch
      t.string :center
      t.string :member
      t.date :cut_off_date
      t.date :start_date
      t.date :end_date
      t.string :number_of_days
      t.string :accrued_type
      t.string :status

      t.timestamps
    end
  end
end
