class AddMaxActiveDateToLoans < ActiveRecord::Migration[5.2]
  def change
    add_column :loans, :max_active_date, :date
  end
end
