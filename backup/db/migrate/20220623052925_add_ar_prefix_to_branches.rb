class AddArPrefixToBranches < ActiveRecord::Migration[7.0]
  def change
    add_column :branches, :ar_prefix, :string
  end
end
