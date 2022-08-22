class CreateMembershipPaymentRecords < ActiveRecord::Migration[5.2]
  def change
    create_table :membership_payment_records, id: :uuid do |t|
      t.string :membership_type
      t.string :membership_name
      t.decimal :amount
      t.date :date_paid
      t.string :status
      t.references :member, type: :uuid, foreign_key: true

      t.timestamps
    end
  end
end
