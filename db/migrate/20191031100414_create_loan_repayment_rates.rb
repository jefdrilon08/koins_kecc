class CreateLoanRepaymentRates < ActiveRecord::Migration[5.2]
  def change
    create_table :loan_repayment_rates, id: :uuid do |t|
      t.references :loan, foreign_key: true, type: :uuid
      t.date :as_of
      t.references :branch, foreign_key: true, type: :uuid
      t.references :center, foreign_key: true, type: :uuid
      t.jsonb :data

      t.timestamps
    end
  end
end
