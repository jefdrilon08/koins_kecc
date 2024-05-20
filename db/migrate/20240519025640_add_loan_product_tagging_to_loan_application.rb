class AddLoanProductTaggingToLoanApplication < ActiveRecord::Migration[7.1]
  def change
    add_reference :loan_applications, :loan_product_tagging, foreign_key: true, type: :uuid
  end
end
