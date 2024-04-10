class AddCoMakerMemberToLoanApplications < ActiveRecord::Migration[7.1]
  def change
    add_column :loan_applications, :co_maker_member_id, :uuid
    add_foreign_key :loan_applications, :members, column: :co_maker_member_id, type: :uuid
  end
end
