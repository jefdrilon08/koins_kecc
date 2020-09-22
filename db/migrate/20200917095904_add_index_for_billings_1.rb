class AddIndexForBillings1 < ActiveRecord::Migration[6.0]
  def change
    add_index(
      :billings, 
      [:status, :collection_date], 
      name: 'idx_billings_status_collection_date'
    )
  end
end
