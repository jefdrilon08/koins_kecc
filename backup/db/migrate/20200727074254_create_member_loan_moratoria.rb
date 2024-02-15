class CreateMemberLoanMoratoria < ActiveRecord::Migration[6.0]
  def change
    create_table :member_loan_moratoria, id: :uuid do |t|
      t.references :member_moratorium, foreign_key: true, type: :uuid
      t.references :loan, null: false, foreign_key: true, foreign_key: true, type: :uuid
      t.references :branch, null: false, foreign_key: true, type: :uuid
      t.references :center, null: false, foreign_key: true, type: :uuid
      t.references :member, null: false, foreign_key: true, type: :uuid
      t.date :date_initialized
      t.integer :number_of_daynumber_of_days
      t.string :status
      t.jsonb :data

      t.timestamps
    end
  end
end
