class CreateCalamityClaims < ActiveRecord::Migration[5.2]
  def change
    create_table :calamity_claims, id: :uuid do |t|
    	t.references :member, type: :uuid, foreign_key: true
    	t.references :center, type: :uuid, foreign_key: true
        t.references :branch, type: :uuid, foreign_key: true
        t.date :date_requested
        t.date :purpose
        t.date :type_of_calamity
        t.date :amount
        t.date :date_of_event
        t.date :date_approved
        t.date :date_of_notification
        t.date :name_of_payee
        t.date :name_of_beneficiary
        t.date :prepared_by
      t.timestamps
    end
  end
end
