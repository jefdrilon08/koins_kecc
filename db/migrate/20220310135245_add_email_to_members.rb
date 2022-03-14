class AddEmailToMembers < ActiveRecord::Migration[6.1]
  def change
    add_column :members, :email, :string
  end
end
