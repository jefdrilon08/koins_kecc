class AddModifiableToMembers < ActiveRecord::Migration[5.2]
  def change
    add_column :members, :modifiable, :boolean
  end
end
