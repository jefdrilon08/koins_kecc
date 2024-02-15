class AddOrCurrentMaxToBranches < ActiveRecord::Migration[7.0]
  def change
    add_column :branches, :or_current_max, :integer
  end
end
