class AddEncryptedPasswordToMembers < ActiveRecord::Migration[6.1]
  def change
    add_column :members, :encrypted_password, :string
  end
end
