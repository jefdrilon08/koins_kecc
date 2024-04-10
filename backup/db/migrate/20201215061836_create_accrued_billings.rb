class CreateAccruedBillings < ActiveRecord::Migration[6.0]
  def change
    create_table :accrued_billings, id: :uuid do |t|
      t.date :collection_date
      t.json :data
      t.string :status
      t.date :date_approved

      t.timestamps
    end
  end
end
