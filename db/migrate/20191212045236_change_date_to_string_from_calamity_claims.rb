class ChangeDateToStringFromCalamityClaims < ActiveRecord::Migration[5.2]
  def change
  	change_column :calamity_claims, :purpose, :string
  	change_column :calamity_claims, :type_of_calamity, :string
  	change_column :calamity_claims, :amount, :string
  	change_column :calamity_claims, :name_of_payee, :string
  	change_column :calamity_claims, :name_of_beneficiary, :string
  	change_column :calamity_claims, :prepared_by, :string
  end
end
