class AddCoMakerFirstNameAndCoMakerLastNameToLoanApplications < ActiveRecord::Migration[7.1]
  def change
    add_column :loan_applications, :co_maker_first_name, :string, null: false
    add_column :loan_applications, :co_maker_last_name, :string, null: false
  end
end
