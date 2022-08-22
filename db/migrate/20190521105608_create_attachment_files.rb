class CreateAttachmentFiles < ActiveRecord::Migration[5.2]
  def change
    create_table :attachment_files, id: :uuid do |t|
      t.references :member, type: :uuid, foreign_key: true
      t.string :file_name
      t.jsonb :data

      t.timestamps
    end
  end
end
