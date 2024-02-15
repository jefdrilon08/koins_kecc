class CreateMemberAccountValidations < ActiveRecord::Migration[5.2]
  def change
    create_table :member_account_validations, id: :uuid do |t|
    	t.references :branch, type: :uuid, foreign_key: true
    	t.date :date_prepared
      	t.string :status
      	t.string :prepared_by
      	t.string :approved_by
      	t.text :particular
      	t.string :reference_number
      	t.decimal :total
      	t.string :or_number
      	t.date :date_approved
      	t.date :date_validated
      	t.string :validated_by
      	t.date :date_checked
      	t.string :checked_by
      	t.date :date_cancelled
      	t.string :cancelled_by
      	t.boolean :is_remote
      	t.decimal :total_rf
      	t.decimal :total_50_percent_lif
      	t.decimal :total_advance_lif
      	t.decimal :total_advance_rf
      	t.decimal :total_interest
      	t.decimal :total_equity_interest

      t.timestamps
    end
  end
end