class AddLoanProductTaggingToLoan < ActiveRecord::Migration[7.1]
  def change
    add_column :loans, :loan_product_tagging_id, :string
  end
end
