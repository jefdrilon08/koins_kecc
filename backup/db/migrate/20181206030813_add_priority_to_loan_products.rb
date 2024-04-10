class AddPriorityToLoanProducts < ActiveRecord::Migration[5.2]
  def change
    add_column :loan_products, :priority, :integer
  end
end
