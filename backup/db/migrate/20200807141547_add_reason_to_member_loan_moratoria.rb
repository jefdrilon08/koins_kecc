class AddReasonToMemberLoanMoratoria < ActiveRecord::Migration[6.0]
  def change
    add_column :member_loan_moratoria, :reason, :string
  end
end
