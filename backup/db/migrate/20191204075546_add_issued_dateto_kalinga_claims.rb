class AddIssuedDatetoKalingaClaims < ActiveRecord::Migration[5.2]
  def change
  	add_column :kalinga_claims, :issueddate, :date
  end
end
