class AddArCounterToBranches < ActiveRecord::Migration[7.0]
  def change
    add_column :branches, :ar_counter, :integer, default: 0
  end
end
