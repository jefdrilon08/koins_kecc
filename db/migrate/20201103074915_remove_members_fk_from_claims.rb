class RemoveMembersFkFromClaims < ActiveRecord::Migration[6.0]
  def change
  	if foreign_key_exists?(:claims, :members)
      remove_foreign_key :claims, :members
    end
  end
end
