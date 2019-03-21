class AddIsVoidToMemberShares < ActiveRecord::Migration[5.2]
  def change
    add_column :member_shares, :is_void, :boolean
  end
end
