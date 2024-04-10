class CreateKjspClaims < ActiveRecord::Migration[5.2]
  def change
    create_table :kjsp_claims, id: :uuid do |t|
    	t.references :member, type: :uuid, foreign_key: true
    	t.references :center, type: :uuid, foreign_key: true
        t.references :branch, type: :uuid, foreign_key: true
    	t.date :date_prepared
    	t.string :name_of_kjsp_beneficiary
    	t.string :payee
    	t.string :amount
    	t.string :name_of_school
    	t.string :school_year
    	t.string :year_level
    	t.string :sem
    	t.string :kjsp_type
    	t.string :final_grade
    	t.string :remarks
      t.timestamps
    end
  end
end
