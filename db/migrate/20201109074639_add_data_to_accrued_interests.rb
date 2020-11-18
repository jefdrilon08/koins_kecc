class AddDataToAccruedInterests < ActiveRecord::Migration[6.0]
  def change
    add_column :accrued_interests, :data, :json
  end
end
