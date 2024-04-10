class AddMonthAndYearToDwBranchActiveLoanCounts < ActiveRecord::Migration[6.1]
  def change
    add_column :dw_branch_active_loan_counts, :month, :integer
    add_column :dw_branch_active_loan_counts, :year, :integer
  end
end
