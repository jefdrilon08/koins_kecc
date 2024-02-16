class AddFirstDateOfPaymentToLoans < ActiveRecord::Migration[5.2]
  def change
    add_column :loans, :first_date_of_payment, :date
  end
end
