class CreateProjectTypeCategories < ActiveRecord::Migration[5.2]
  def change
    create_table :project_type_categories, id: :uuid do |t|
      t.string :name
      t.string :code

      t.timestamps
    end
  end
end
