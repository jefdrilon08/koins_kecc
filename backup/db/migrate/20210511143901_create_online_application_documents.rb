class CreateOnlineApplicationDocuments < ActiveRecord::Migration[6.1]
  def change
    create_table :online_application_documents, id: :uuid do |t|
      t.string :file_name
      t.jsonb :data
      t.references :online_application, null: false, foreign_key: true, type: :uuid

      t.timestamps
    end
  end
end
