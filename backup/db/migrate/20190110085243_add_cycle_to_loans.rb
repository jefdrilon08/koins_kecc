class AddCycleToLoans < ActiveRecord::Migration[5.2]
  def change
    add_column :loans, :cycle, :integer
  end
end
