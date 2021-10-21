class CreateReferrers < ActiveRecord::Migration[6.1]
  def change
    create_table :referrers, id: :uuid do |t|
      t.string :first_name
      t.string :middle_name
      t.string :last_name
      t.string :status
      t.string :contact_number
      t.jsonb :data

      t.timestamps
    end
  end
end
