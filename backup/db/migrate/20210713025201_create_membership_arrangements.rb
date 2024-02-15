class CreateMembershipArrangements < ActiveRecord::Migration[6.1]
  def change
    create_table :membership_arrangements, id: :uuid do |t|
      t.string :name
      t.jsonb :data

      t.timestamps
    end
  end
end
