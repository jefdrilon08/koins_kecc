class AddMonthAndYearToDwBranchNewMemberCounts < ActiveRecord::Migration[6.1]
  def change
    add_column :dw_branch_new_member_counts, :month, :integer
    add_column :dw_branch_new_member_counts, :year, :integer
  end
end
