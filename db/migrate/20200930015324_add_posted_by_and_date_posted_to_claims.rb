class AddPostedByAndDatePostedToClaims < ActiveRecord::Migration[6.0]
  def change
  	add_column :claims, :posted_by, :string
  	add_column :claims, :date_posted, :date
  end
end
