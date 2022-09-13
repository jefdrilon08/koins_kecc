class AddIsActiveToProjectTypeCategory < ActiveRecord::Migration[7.0]
  def change
    add_column :project_type_categories, :is_active, :boolean
  end
end
