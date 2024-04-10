class CreateMembers < ActiveRecord::Migration[5.2]
  def change
    create_table :members, id: :uuid do |t|
      t.references :center, type: :uuid, foreign_key: true
      t.references :branch, type: :uuid, foreign_key: true
      t.string :first_name
      t.string :middle_name
      t.string :last_name
      t.string :gender
      t.date :date_of_birth
      t.string :civil_status
      t.string :home_number
      t.string :mobile_number
      t.string :processed_by
      t.string :approved_by
      t.string :identification_number
      t.string :place_of_birth
      t.string :status
      t.string :member_type
      t.string :religion
      t.string :insurance_status
      t.json :data
      t.date :date_resigned
      t.json :meta

      t.timestamps
    end
  end
end
