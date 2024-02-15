class AddAgreedToDpTermsToOnlineApplications < ActiveRecord::Migration[6.1]
  def change
    add_column :online_applications, :agreed_to_dp_terms, :boolean
  end
end
