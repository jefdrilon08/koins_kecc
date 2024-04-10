class AddAmountDisbursedToDwBranchMonthlyLoanProductDisbursedCount < ActiveRecord::Migration[6.1]
  def change
    add_column :dw_branch_monthly_loan_product_disbursed_counts, :amount, :decimal
  end
end
