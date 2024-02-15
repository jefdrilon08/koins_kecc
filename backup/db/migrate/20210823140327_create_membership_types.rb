class CreateMembershipTypes < ActiveRecord::Migration[6.1]
  def change
    create_table :membership_types, id: :uuid do |t|
      t.string :name
      t.jsonb :data

      t.timestamps
    end
  end
end
