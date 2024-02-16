class CreateBeneficiaries < ActiveRecord::Migration[5.2]
  def change
    create_table :beneficiaries, id: :uuid do |t|
      t.references :member, type: :uuid, foreign_key: true
      t.string :first_name
      t.string :middle_name
      t.string :last_name
      t.string :relationship
      t.date :date_of_birth
      t.boolean :is_primary
      t.boolean :is_deceased

      t.timestamps
    end
  end
end
