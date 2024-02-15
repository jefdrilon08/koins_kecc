class AddExternalRefToClaims < ActiveRecord::Migration[7.0]
  def change
    add_column :claims, :external_ref, :uuid
  end
end
