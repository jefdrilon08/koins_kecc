class AddMemberToRecomputeRestructure < ActiveRecord::Migration[6.0]
  def change
    add_column :recompute_restructures, :member, :string
  end
end
