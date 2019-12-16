class AddMemberIdAndMemberBranchToKalingaClaim < ActiveRecord::Migration[5.2]
  def change
  	add_column :kalinga_claims, :member_branch, :string
  	add_column :kalinga_claims, :member_identification_number, :string
  end
end
