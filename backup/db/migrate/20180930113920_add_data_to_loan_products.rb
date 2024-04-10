class AddDataToLoanProducts < ActiveRecord::Migration[5.2]
  def change
    add_column :loan_products, :data, :json
  end
end
