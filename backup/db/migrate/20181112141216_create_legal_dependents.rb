class CreateLegalDependents < ActiveRecord::Migration[5.2]
  def change
    create_table :legal_dependents, id: :uuid do |t|
      t.string :first_name
      t.string :middle_name
      t.date :date_of_birth
      t.references :member, type: :uuid, foreign_key: true
      t.string :relationship
      t.json :data

      t.timestamps
    end
  end
end
