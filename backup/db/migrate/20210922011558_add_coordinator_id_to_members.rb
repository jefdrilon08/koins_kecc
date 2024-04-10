class AddCoordinatorIdToMembers < ActiveRecord::Migration[6.1]
  def change
    add_column :members, :coordinator_id, :uuid
  end
end
