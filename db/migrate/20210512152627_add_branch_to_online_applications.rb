class AddBranchToOnlineApplications < ActiveRecord::Migration[6.1]
  def change
    add_reference :online_applications, :branch, null: true, foreign_key: true, type: :uuid
  end
end
