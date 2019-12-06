class RemoveMemberIdBranchIdCenterIdFromKalingaClaims < ActiveRecord::Migration[5.2]
  def change
  	 remove_reference :kalinga_claims, :member, index: true, foreign_key: true
  	 remove_reference :kalinga_claims, :branch, index: true, foreign_key: true
  	 remove_reference :kalinga_claims, :center, index: true, foreign_key: true
  end
end
