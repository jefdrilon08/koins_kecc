class CreateClaims < ActiveRecord::Migration[5.2]
  def change
    create_table :claims, id: :uuid do |t|
      	t.references :member, type: :uuid, foreign_key: true
    	  t.references :center, type: :uuid, foreign_key: true
        t.references :branch, type: :uuid, foreign_key: true
      	t.date :date_prepared
      	t.string :policy_number
      	t.string :type_of_insurance_policy
      	t.string :name_of_insured
      	t.string :beneficiary
      	t.string :classification_of_insured
      	t.date :date_of_birth
      	t.string :gender
      	t.date :date_of_policy_issue
      	t.decimal :face_amount
      	t.date :date_of_death_tpd_accident
      	t.decimal :arrears
      	t.text :cause_of_death_tpd_accident
      	t.decimal :amount_benefit_payable
      	t.decimal :equity_value
      	t.decimal :retirement_fund
      	t.string :prepared_by
      	t.string :length_of_stay
      	t.decimal :returned_contribution
      	t.decimal :total_amount_payable
      	t.string :order_of_child
      	t.string :category_of_cause_of_death_tpd_accident
      	t.date :date_reported
      	t.date :date_paid
      	t.timestamps null: false
    end
  end
end