class AddDataToMemberAccounts < ActiveRecord::Migration[5.2]
  def change
    add_column :member_accounts, :data, :json
  end
end
