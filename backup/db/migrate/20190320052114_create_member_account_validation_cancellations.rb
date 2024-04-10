class CreateMemberAccountValidationCancellations < ActiveRecord::Migration[5.2]
  def change
    create_table :member_account_validation_cancellations, id: :uuid do |t|
    	t.references :member_account_validation, type: :uuid, foreign_key: true, index: {:name => "index_member_account_validation_cancellations_uniqueness"}
    	t.references :member, type: :uuid, foreign_key: true
    	t.references :branch, type: :uuid, foreign_key: true
      	t.text :reason
      	t.date :date_cancelled

      t.timestamps
    end
  end
end
