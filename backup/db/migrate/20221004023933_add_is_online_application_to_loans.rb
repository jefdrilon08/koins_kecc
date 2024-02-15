class AddIsOnlineApplicationToLoans < ActiveRecord::Migration[7.0]
  def change
    add_column :loans, :is_online_application, :boolean
  end
end
