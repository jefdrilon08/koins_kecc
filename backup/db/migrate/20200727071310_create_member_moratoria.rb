class CreateMemberMoratoria < ActiveRecord::Migration[6.0]
  def change
    create_table :member_moratoria, id: :uuid do |t|
      t.string :status
      t.references :branch, null: false, foreign_key: true, type: :uuid
      t.references :center, null: false, foreign_key: true, type: :uuid
      t.references :member, null: false, foreign_key: true, type: :uuid
      t.date :date_initialized
      t.integer :number_of_daynumber_of_days
      t.jsonb :data

      t.timestamps
    end
  end
end
