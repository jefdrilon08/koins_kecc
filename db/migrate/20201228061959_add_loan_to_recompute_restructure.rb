class AddLoanToRecomputeRestructure < ActiveRecord::Migration[6.0]
  def change
    add_column :recompute_restructures, :loan, :string
  end
end
