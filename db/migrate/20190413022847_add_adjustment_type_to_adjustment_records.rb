class AddAdjustmentTypeToAdjustmentRecords < ActiveRecord::Migration[5.2]
  def change
    add_column :adjustment_records, :adjustment_type, :string
  end
end
