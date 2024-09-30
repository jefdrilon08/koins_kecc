class AddInforceCountAndLapsedCountAndPendingCountToApiReceiveMember < ActiveRecord::Migration[7.1]
  def change
    add_column :api_receive_members, :inforce_count, :integer
    add_column :api_receive_members, :lapsed_count, :integer
    add_column :api_receive_members, :pending_count, :integer
  end
end
