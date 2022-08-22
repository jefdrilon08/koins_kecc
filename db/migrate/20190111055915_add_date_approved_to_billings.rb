class AddDateApprovedToBillings < ActiveRecord::Migration[5.2]
  def change
    add_column :billings, :date_approved, :date
  end
end
