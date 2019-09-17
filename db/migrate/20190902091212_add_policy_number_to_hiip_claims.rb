class AddPolicyNumberToHiipClaims < ActiveRecord::Migration[5.2]
  def change
    add_column :hiip_claims, :policy_number, :string
  end
end
