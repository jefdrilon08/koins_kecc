class CreateMemberAccountValidationRecords < ActiveRecord::Migration[5.2]
  def change
    create_table :member_account_validation_records, id: :uuid do |t|
    	t.references :member_account_validation, type: :uuid, foreign_key: true, index: {:name => "index_member_account_validation_records_uniqueness"}
    	t.references :member, type: :uuid, foreign_key: true
    	t.references :center, type: :uuid, foreign_key: true
      t.string :status
      t.string :transaction_number
      t.decimal :rf
      t.decimal :lif_50_percent
      t.decimal :advance_rf
      t.decimal :interest
      t.decimal :equity_interest
      t.decimal :total
      t.date :resignation_date
      t.string :member_classification
      	
      t.timestamps
    end
  end
end
