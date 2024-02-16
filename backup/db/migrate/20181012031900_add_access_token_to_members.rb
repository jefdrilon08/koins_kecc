class AddAccessTokenToMembers < ActiveRecord::Migration[5.2]
  def change
    add_column :members, :access_token, :string
  end
end
