class AddDateApprovedToLoanApplication < ActiveRecord::Migration[7.1]
  def change
    add_column :loan_applications, :date_approved, :date
  end
end
