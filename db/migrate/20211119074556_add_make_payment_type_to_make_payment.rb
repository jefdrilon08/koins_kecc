class AddMakePaymentTypeToMakePayment < ActiveRecord::Migration[6.1]
  def change
    add_column :make_payments, :make_payment_type, :string
  end
end
