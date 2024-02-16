class AddSignatureDataToMembers < ActiveRecord::Migration[5.2]
  def change
    add_column :members, :signature_data, :text
  end
end
