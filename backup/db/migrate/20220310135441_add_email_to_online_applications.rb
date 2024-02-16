class AddEmailToOnlineApplications < ActiveRecord::Migration[6.1]
  def change
    add_column :online_applications, :email, :string
  end
end
