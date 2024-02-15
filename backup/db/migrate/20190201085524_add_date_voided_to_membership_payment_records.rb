class AddDateVoidedToMembershipPaymentRecords < ActiveRecord::Migration[5.2]
  def change
    add_column :membership_payment_records, :date_voided, :date
  end
end
