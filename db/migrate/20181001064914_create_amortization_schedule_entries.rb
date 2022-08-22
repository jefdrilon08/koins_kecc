class CreateAmortizationScheduleEntries < ActiveRecord::Migration[5.2]
  def change
    create_table :amortization_schedule_entries, id: :uuid do |t|
      t.decimal :amount_due
      t.decimal :principal
      t.decimal :interest
      t.decimal :principal_paid
      t.decimal :interest_paid
      t.decimal :principal_balance
      t.decimal :interest_balance
      t.date :due_date
      t.boolean :is_paid
      t.references :loan, type: :uuid, foreign_key: true
      t.json :data

      t.timestamps
    end
  end
end
