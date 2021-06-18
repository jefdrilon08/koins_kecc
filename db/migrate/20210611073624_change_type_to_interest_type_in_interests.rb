class ChangeTypeToInterestTypeInInterests < ActiveRecord::Migration[6.1]
  def change
  	rename_column :interests, :type, :interest_type
  end
end
