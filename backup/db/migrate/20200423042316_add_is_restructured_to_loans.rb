class AddIsRestructuredToLoans < ActiveRecord::Migration[5.2]
  def change
    add_column :loans, :is_restructured, :boolean
  end
end
