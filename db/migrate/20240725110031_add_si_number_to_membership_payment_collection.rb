class AddSiNumberToMembershipPaymentCollection < ActiveRecord::Migration[7.1]
  def change
    add_column :membership_payment_collections, :si_number, :string
  end
end
