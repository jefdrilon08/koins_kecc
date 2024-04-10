class AddLoanProductCategoryToLoanProducts < ActiveRecord::Migration[6.1]
  def change
    add_reference :loan_products, :loan_product_category, null: true, foreign_key: true, type: :uuid
  end
end
