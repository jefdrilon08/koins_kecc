class AddReferenceNumberIndexForOnlineApplications < ActiveRecord::Migration[6.1]
  def change
    add_index(
      :online_applications,
      :reference_number,
      name: 'idx_online_applications_reference_number'
    )
  end
end
