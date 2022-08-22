class CreateKalingaClaims < ActiveRecord::Migration[5.2]
  def change
    create_table :kalinga_claims, id: :uuid do |t|
    	t.references :member, type: :uuid, foreign_key: true
    	t.references :center, type: :uuid, foreign_key: true
        t.references :branch, type: :uuid, foreign_key: true
        t.date :date_reported
        t.date :date_emailed
        t.date :date_approved
        t.date :date_requested
        t.string :purpose
        t.decimal :amount
        t.date :effective_date
        t.date :expiration_date
        t.string :poc_number
        t.string :name_of_insured
        t.string :relationship_to_member
        t.string :name_of_payee
        t.boolean :is_member
        t.string :insured_address
        t.string :civil_status
        t.date :date_of_birth
        t.string :name_of_beneficiary
        t.date :date_of_death_or_incident
        t.text :reason_of_death
        t.string :gender
        t.string :prepared_by
     
      t.timestamps
    end
  end
end
