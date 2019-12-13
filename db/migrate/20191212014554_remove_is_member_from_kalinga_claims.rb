class RemoveIsMemberFromKalingaClaims < ActiveRecord::Migration[5.2]
  def change
  	remove_column :kalinga_claims, :is_member, :boolean
  end
end
