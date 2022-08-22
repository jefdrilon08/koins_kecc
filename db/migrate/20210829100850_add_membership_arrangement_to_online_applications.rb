class AddMembershipArrangementToOnlineApplications < ActiveRecord::Migration[6.1]
  def change
    add_reference :online_applications, :membership_arrangement, null: true, foreign_key: true, type: :uuid
  end
end
