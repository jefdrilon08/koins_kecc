class FixDwBranchPureSaversMemberCounts < ActiveRecord::Migration[6.1]
  def change
    remove_column :dw_branch_member_counts, :gender
    remove_column :dw_branch_member_counts, :count

    add_column :dw_branch_member_counts, :count_male, :integer
    add_column :dw_branch_member_counts, :count_female, :integer
    add_column :dw_branch_member_counts, :total, :integer
  end
end
