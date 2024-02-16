class AddDataAndClaimTypeToAllClaims < ActiveRecord::Migration[5.2]
  def change
  	add_column :claims, :claim_type, :string
  	add_column :claims, :data, :json
  	add_column :clip_claims, :claim_type, :string
  	add_column :clip_claims, :data, :json
  	add_column :hiip_claims, :claim_type, :string
  	add_column :hiip_claims, :data, :json
    add_column :hiip_claims, :date_prepared, :date
  	add_column :kalinga_claims, :claim_type, :string
  	add_column :kalinga_claims, :data, :json
  	add_column :calamity_claims, :claim_type, :string
  	add_column :calamity_claims, :data, :json
  	add_column :kbente_claims, :claim_type, :string
  	add_column :kbente_claims, :data, :json
  	add_column :kjsp_claims, :claim_type, :string
  	add_column :kjsp_claims, :data, :json
  end
end
