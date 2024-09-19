class CreateApiReceiveMembers < ActiveRecord::Migration[7.1]
  def change
    create_table :api_receive_members, id: :uuid do |t|
      t.date :receive_date
      t.string :api_from
      t.uuid :branch_id
      t.json :data
      t.string :status
      t.date :date_approve

      t.timestamps
    end
  end
end
