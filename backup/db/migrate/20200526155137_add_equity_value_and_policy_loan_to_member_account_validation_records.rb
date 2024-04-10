class AddEquityValueAndPolicyLoanToMemberAccountValidationRecords < ActiveRecord::Migration[5.2]
  def change
  	add_column :member_account_validation_records, :equity_value, :decimal
  	add_column :member_account_validation_records, :policy_loan, :decimal
  end
end
