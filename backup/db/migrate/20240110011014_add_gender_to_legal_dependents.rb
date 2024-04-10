class AddGenderToLegalDependents < ActiveRecord::Migration[7.0]
  def change
    add_column :legal_dependents, :gender, :string
  end
end
