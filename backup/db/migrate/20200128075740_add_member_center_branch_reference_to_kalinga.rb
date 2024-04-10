class AddMemberCenterBranchReferenceToKalinga < ActiveRecord::Migration[5.2]
  def change
      if column_exists? :kalinga_claims, :name_of_member
              remove_column :kalinga_claims, :name_of_member
      end
      
      if column_exists? :kalinga_claims, :member_identification_number
              remove_column :kalinga_claims, :member_identification_number
      end

      if column_exists? :kalinga_claims, :member_branch
              remove_column :kalinga_claims, :member_branch
      end

      if column_exists? :kalinga_claims, :member_center
              remove_column :kalinga_claims, :member_center
      end

    change_table(:kalinga_claims) do |t|   
      t.references :member, type: :uuid,  index: true, foreign_key: true
      t.references :center, type: :uuid,  index: true, foreign_key: true
      t.references :branch, type: :uuid,  index: true, foreign_key: true
    end
  end
end
