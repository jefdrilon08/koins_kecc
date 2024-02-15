class AddIsActiveToProjectType < ActiveRecord::Migration[7.0]
  def change
    add_column :project_types, :is_active, :boolean
  end
end
