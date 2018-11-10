class AddMeetingDayToCenters < ActiveRecord::Migration[5.2]
  def change
    add_column :centers, :meeting_day, :integer
  end
end
