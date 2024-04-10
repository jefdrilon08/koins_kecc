class AddCenterReferencesToOnlineApplications < ActiveRecord::Migration[6.1]
  def change
    add_reference :online_applications, :center, null: true, foreign_key: true, type: :uuid
  end
end
