class AddNumberOfShareToMemberShare < ActiveRecord::Migration[5.2]
  def change
    add_column :member_shares, :number_of_shares, :integer
  end
end
