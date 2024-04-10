class AddDateOfIssueToMemberShares < ActiveRecord::Migration[5.2]
  def change
    add_column :member_shares, :date_of_issue, :date
  end
end
