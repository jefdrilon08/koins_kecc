class ChangeRecordIdTypeUsingDropAndCreateColumn < ActiveRecord::Migration[5.2]
  def change
  	remove_column :active_storage_attachments, :record_id, :bigint
  	add_column :active_storage_attachments, :record_id, :uuid
  end
end
