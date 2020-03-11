class AddOriginalMaturityDateToLoans < ActiveRecord::Migration[5.2]
  def change
    add_column :loans, :original_maturity_date, :date
  end
end
