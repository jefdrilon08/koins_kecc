class CreateClipClaims < ActiveRecord::Migration[5.2]
  def change
    create_table :clip_claims, id: :uuid do |t|
    	  t.references :member, type: :uuid, foreign_key: true
    	  t.references :center, type: :uuid, foreign_key: true
        t.references :branch, type: :uuid, foreign_key: true
      	t.date :date_prepared
      	t.string :creditors_name
      	t.string :policy_number
      	t.date :date_of_birth
      	t.string :member_name
      	t.string :beneficiary
      	t.string :gender
      	t.string :age
      	t.date :date_of_death
      	t.text :cause_of_death
		    t.date :effective_date_of_coverage
		    t.date :expiration_date_of_coverage      	
      	t.decimal :amount_of_loan
      	t.string :terms
      	t.decimal :amount_payable_to_beneficiary
      	t.string :prepared_by
      	t.decimal :amount_payable_to_creditor
    	  t.string :type_of_loan
      	t.timestamps null: false
    end
  end
end

    	