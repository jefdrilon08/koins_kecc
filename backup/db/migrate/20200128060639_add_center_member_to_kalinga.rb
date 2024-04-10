class AddCenterMemberToKalinga < ActiveRecord::Migration[5.2]
  def change
  	add_column :kalinga_claims, :member_center, :string
  end
end
