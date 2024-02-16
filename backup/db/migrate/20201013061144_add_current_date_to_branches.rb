class AddCurrentDateToBranches < ActiveRecord::Migration[6.0]
  def change
    add_column :branches, :current_date, :date
  end
end
