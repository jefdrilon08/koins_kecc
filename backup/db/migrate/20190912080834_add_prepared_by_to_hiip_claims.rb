class AddPreparedByToHiipClaims < ActiveRecord::Migration[5.2]
  def change
  	add_column :hiip_claims, :prepared_by, :string
  end
end
