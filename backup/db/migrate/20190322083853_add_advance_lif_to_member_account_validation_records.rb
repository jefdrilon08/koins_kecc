class AddAdvanceLifToMemberAccountValidationRecords < ActiveRecord::Migration[5.2]
  def change
  	add_column :member_account_validation_records, :advance_lif, :decimal
  	add_column :member_account_validation_records, :data, :json
  end
end
