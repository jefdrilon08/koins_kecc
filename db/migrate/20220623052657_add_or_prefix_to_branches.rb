class AddOrPrefixToBranches < ActiveRecord::Migration[7.0]
  def change
    add_column :branches, :or_prefix, :string
  end
end
