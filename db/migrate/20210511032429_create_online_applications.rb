class CreateOnlineApplications < ActiveRecord::Migration[6.1]
  def change
    create_table :online_applications, id: :uuid do |t|
      t.string :first_name
      t.string :middle_name
      t.string :last_name
      t.string :gender
      t.date :date_of_birth
      t.string :civil_status
      t.string :home_number
      t.string :mobile_number
      t.string :reference_number
      t.string :status
      t.string :place_of_birth
      t.string :religion
      t.jsonb :data

      t.timestamps
    end
  end
end
