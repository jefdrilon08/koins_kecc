class AddCountOthersDwBranchMemberCounts < ActiveRecord::Migration[6.1]
  def change
    add_column :dw_branch_member_counts, :count_others, :integer
  end
end
