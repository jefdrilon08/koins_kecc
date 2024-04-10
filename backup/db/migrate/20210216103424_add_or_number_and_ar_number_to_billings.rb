class AddOrNumberAndArNumberToBillings < ActiveRecord::Migration[6.1]
  def change
    add_column :billings, :or_number, :string
    add_column :billings, :ar_number, :string
  end
end
