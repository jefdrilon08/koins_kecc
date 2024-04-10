class AddRecordTypeToDwBranchMemberCounts < ActiveRecord::Migration[6.1]
  def change
    add_column :dw_branch_member_counts, :record_type, :string
  end
end
