class AddOrCounter < ActiveRecord::Migration[7.0]
  def change
    add_column :branches, :or_counter, :integer, default: 0
  end
end
