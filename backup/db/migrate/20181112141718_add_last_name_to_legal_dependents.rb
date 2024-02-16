class AddLastNameToLegalDependents < ActiveRecord::Migration[5.2]
  def change
    add_column :legal_dependents, :last_name, :string
  end
end
