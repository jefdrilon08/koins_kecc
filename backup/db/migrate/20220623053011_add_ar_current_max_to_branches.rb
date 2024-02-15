class AddArCurrentMaxToBranches < ActiveRecord::Migration[7.0]
  def change
    add_column :branches, :ar_current_max, :integer
  end
end
