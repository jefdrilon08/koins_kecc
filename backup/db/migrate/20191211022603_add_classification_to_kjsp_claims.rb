class AddClassificationToKjspClaims < ActiveRecord::Migration[5.2]
  def change
  	add_column :kjsp_claims, :classification, :string
  	add_column :kjsp_claims, :received_by, :string
  end
end
