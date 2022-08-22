class AddApprovedByToSavingsInsuranceTransferCollections < ActiveRecord::Migration[5.2]
  def change
    add_column :savings_insurance_transfer_collections, :approved_by, :string
  end
end
