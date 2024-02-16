class AddTotalPolicyLoanToMemberAccountValidation < ActiveRecord::Migration[5.2]
  def change
  	add_column :member_account_validations, :total_policy_loan, :decimal
  end
end
