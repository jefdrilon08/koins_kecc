class AddNumberOfMoratoiumDayToAccruedInterests < ActiveRecord::Migration[6.0]
  def change
    add_column :accrued_interests, :number_of_moratoium_day, :string
  end
end
