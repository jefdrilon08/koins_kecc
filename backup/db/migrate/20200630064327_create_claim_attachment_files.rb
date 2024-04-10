class CreateClaimAttachmentFiles < ActiveRecord::Migration[6.0]
  def change
    create_table :claim_attachment_files, id: :uuid do |t|
      t.references :claim, type: :uuid, foreign_key: true
      t.string :file_name
      t.jsonb :data	

      t.timestamps
    end
  end
end
