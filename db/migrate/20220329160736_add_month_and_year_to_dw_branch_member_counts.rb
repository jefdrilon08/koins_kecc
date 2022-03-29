class AddMonthAndYearToDwBranchMemberCounts < ActiveRecord::Migration[6.1]
  def change
    add_column :dw_branch_member_counts, :month, :integer
    add_column :dw_branch_member_counts, :year, :integer
  end
end
