class CreateKbenteClaims < ActiveRecord::Migration[5.2]
  def change
    create_table :kbente_claims, id: :uuid do |t|
    	t.references :member, type: :uuid, foreign_key: true
    	t.references :center, type: :uuid, foreign_key: true
        t.references :branch, type: :uuid, foreign_key: true
        t.date :date_reported
        t.date :date_emailed
        t.date :date_approved
        t.date :date_requested
        t.string :purpose
        t.decimal :amount
        t.string :prepared_by
        t.string :name_of_insured
        t.string :name_of_beneficiary
        t.string :classification
        t.date :date_of_death
      t.timestamps
    end
  end
end
