class AddGenderToDwBranchMemberCounts < ActiveRecord::Migration[6.1]
  def change
    add_column :dw_branch_member_counts, :gender, :string
  end
end
