class AdjustMemberLoanMoratoriaFields < ActiveRecord::Migration[6.0]
  def change
    remove_column :member_loan_moratoria, :number_of_daynumber_of_days
    add_column :member_loan_moratoria, :number_of_days, :integer
  end
end
