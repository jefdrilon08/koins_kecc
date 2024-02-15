class AddMobileNumberIndexToOnlineApplications < ActiveRecord::Migration[6.1]
  def change
    add_index(
      :online_applications,
      :mobile_number,
      name: 'idx_mobile_number_oa'
    )
  end
end
