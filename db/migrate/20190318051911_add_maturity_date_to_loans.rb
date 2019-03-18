class AddMaturityDateToLoans < ActiveRecord::Migration[5.2]
  def change
    add_column :loans, :maturity_date, :date
  end
end
