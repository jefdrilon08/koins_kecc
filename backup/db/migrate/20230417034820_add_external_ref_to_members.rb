class AddExternalRefToMembers < ActiveRecord::Migration[7.0]
  def change
    add_column :members, :external_ref, :uuid
  end
end
