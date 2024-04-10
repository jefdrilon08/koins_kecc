class AddTotalAmountToSavingsInsuranceTransferCollections < ActiveRecord::Migration[5.2]
  def change
    add_column :savings_insurance_transfer_collections, :total_amount, :decimal, precision: 8, scale: 2, default: 0.00
  end
end
