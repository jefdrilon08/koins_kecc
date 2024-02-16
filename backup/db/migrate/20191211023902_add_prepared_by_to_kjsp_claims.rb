class AddPreparedByToKjspClaims < ActiveRecord::Migration[5.2]
  def change
  	add_column :kjsp_claims, :prepared_by, :string
  end
end
