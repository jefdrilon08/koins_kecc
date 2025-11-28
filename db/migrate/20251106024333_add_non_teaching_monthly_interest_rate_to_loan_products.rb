class AddNonTeachingMonthlyInterestRateToLoanProducts < ActiveRecord::Migration[7.1]
  def change
    add_column :loan_products, :non_teaching_monthly_interest_rate, :decimal
  end
end
