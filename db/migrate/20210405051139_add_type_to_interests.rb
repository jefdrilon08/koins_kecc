class AddTypeToInterests < ActiveRecord::Migration[6.1]
  def change
  	add_column :interests, :type, :string
  end
end
