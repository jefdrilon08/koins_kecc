class RemoveMemberNameOfPayeeFromKalingaClaims < ActiveRecord::Migration[5.2]
  def change
  	remove_column :kalinga_claims, :name_of_payee, :string
    add_column :kalinga_claims, :name_of_member, :string
  end
end
