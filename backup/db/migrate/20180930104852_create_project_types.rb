class CreateProjectTypes < ActiveRecord::Migration[5.2]
  def change
    create_table :project_types, id: :uuid do |t|
      t.string :name
      t.string :code
      t.references :project_type_category, type: :uuid, foreign_key: true

      t.timestamps
    end
  end
end
