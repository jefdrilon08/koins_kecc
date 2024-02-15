class AddLoanProductTypeToLoans < ActiveRecord::Migration[6.1]
  def change
    add_reference :loans, :loan_product_type, null: true, foreign_key: true, type: :uuid
  end
end
