class AddDateApprovedToMembershipPaymentCollections < ActiveRecord::Migration[5.2]
  def change
    add_column :membership_payment_collections, :date_approved, :date
  end
end
