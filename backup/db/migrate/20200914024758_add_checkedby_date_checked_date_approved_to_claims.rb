class AddCheckedbyDateCheckedDateApprovedToClaims < ActiveRecord::Migration[6.0]
  def change
  	add_column :claims, :checked_by, :string
  	add_column :claims, :date_checked, :date
  	add_column :claims, :date_approved, :date
  end
end
