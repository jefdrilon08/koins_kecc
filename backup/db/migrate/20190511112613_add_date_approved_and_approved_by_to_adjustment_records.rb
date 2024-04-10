class AddDateApprovedAndApprovedByToAdjustmentRecords < ActiveRecord::Migration[5.2]
  def change
    add_column :adjustment_records, :date_approved, :date
    add_column :adjustment_records, :approved_by, :string
  end
end
