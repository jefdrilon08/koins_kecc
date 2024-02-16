class CreateMemberShares < ActiveRecord::Migration[5.2]
  def change
    create_table :member_shares, id: :uuid do |t|
      t.references :member, type: :uuid, foreign_key: true
      t.string :certificate_number
      t.jsonb :data

      t.timestamps
    end
  end
end
