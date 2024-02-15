class CreateTransferMemberRecords < ActiveRecord::Migration[6.1]
  def change
    create_table :transfer_member_records, id: :uuid do |t|
      t.string :branch_id
      t.date :transfer_date
      t.string :status
      t.date :date_approved
      t.json :data

      t.timestamps
    end
  end
end
