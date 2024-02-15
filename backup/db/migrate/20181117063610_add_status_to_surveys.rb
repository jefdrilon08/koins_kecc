class AddStatusToSurveys < ActiveRecord::Migration[5.2]
  def change
    remove_column :surveys, :published
    add_column :surveys, :status, :string
  end
end
