class AddMemberBranchCenterToClaims < ActiveRecord::Migration[5.2]
  def change
	    if column_exists? :claims, :member_id
            remove_column :claims, :member_id
      end
      if column_exists? :claims, :center_id
              remove_column :claims, :center_id
      end
      if column_exists? :claims, :branch_id
              remove_column :claims, :branch_id
      end
  	change_table(:claims) do |t|   
  		t.references :member, type: :uuid,  index: true, foreign_key: true
  		t.references :center, type: :uuid,  index: true, foreign_key: true
  		t.references :branch, type: :uuid,  index: true, foreign_key: true
    end
    
  end
end
