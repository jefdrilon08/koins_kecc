class AddMetaToMakePayment < ActiveRecord::Migration[6.1]
  def change
    add_column :make_payments, :meta, :json
  end
end
