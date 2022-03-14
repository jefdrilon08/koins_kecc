class CreateMessages < ActiveRecord::Migration[6.1]
  def change
    create_table :messages, id: :uuid do |t|
      t.string :topic
      t.text :content
      t.references :member, null: false, foreign_key: true, type: :uuid
      t.string :status
      t.references :message, null: true, foreign_key: true, type: :uuid
      t.jsonb :data

      t.timestamps
    end
  end
end
