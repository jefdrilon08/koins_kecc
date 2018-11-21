class AddMemberCounterToBranches < ActiveRecord::Migration[5.2]
  def change
    add_column :branches, :member_counter, :integer
  end
end
