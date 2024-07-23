class AddSiNumberToBilling < ActiveRecord::Migration[7.1]
  def change
    add_column :billings, :si_number, :string
  end
end
