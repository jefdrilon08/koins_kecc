class AddIsActiveToLoanProduct < ActiveRecord::Migration[7.1]
  def change
    add_column :loan_products, :is_active, :boolean
  end
end
