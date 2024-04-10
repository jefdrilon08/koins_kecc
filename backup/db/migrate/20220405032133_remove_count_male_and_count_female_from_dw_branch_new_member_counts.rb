class RemoveCountMaleAndCountFemaleFromDwBranchNewMemberCounts < ActiveRecord::Migration[6.1]
  def change
    remove_column :dw_branch_new_member_counts, :count_male
    remove_column :dw_branch_new_member_counts, :count_female
  end
end
