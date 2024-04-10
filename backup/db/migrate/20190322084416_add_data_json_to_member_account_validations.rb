class AddDataJsonToMemberAccountValidations < ActiveRecord::Migration[5.2]
  def change
  	add_column :member_account_validations, :data, :json
  end
end
