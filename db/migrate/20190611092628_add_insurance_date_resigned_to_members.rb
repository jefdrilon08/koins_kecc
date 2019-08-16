class AddInsuranceDateResignedToMembers < ActiveRecord::Migration[5.2]
  def change
    add_column :members, :insurance_date_resigned, :date
  end
end
