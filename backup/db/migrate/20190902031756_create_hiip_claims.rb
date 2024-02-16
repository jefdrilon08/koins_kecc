class CreateHiipClaims < ActiveRecord::Migration[5.2]
  def change
    create_table :hiip_claims, id: :uuid do |t|
  	    t.references :member, type: :uuid, foreign_key: true
  	    t.references :center, type: :uuid, foreign_key: true
        t.references :branch, type: :uuid, foreign_key: true
        t.date :date_posted
        t.decimal :amount
        t.text :mode_of_payment

      t.timestamps
    end
  end
end
