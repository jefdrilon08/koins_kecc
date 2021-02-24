class AddColorToBranches < ActiveRecord::Migration[6.1]
  def change
    add_column :branches, :color, :string
  end
end
