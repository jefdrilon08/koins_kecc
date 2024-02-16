class AddPreviousDateResignedToMembers < ActiveRecord::Migration[5.2]
  def change
    add_column :members, :previous_date_resigned, :date
  end
end
