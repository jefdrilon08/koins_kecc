class AddUserIdToLoans < ActiveRecord::Migration[5.2]
  def change
    add_column :loans, :user_id, :uuid
  end
end
