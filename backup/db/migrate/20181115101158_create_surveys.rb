class CreateSurveys < ActiveRecord::Migration[5.2]
  def change
    create_table :surveys, id: :uuid do |t|
      t.string :name
      t.boolean :published
      t.jsonb :data

      t.timestamps
    end
  end
end
