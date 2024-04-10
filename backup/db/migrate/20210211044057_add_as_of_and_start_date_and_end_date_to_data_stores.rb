class AddAsOfAndStartDateAndEndDateToDataStores < ActiveRecord::Migration[6.1]
  def change
    add_column :data_stores, :as_of, :date
    add_column :data_stores, :start_date, :date
    add_column :data_stores, :end_date, :date
  end
end
