module Branches
  class FetchCenters
    def initialize(config:)
      @config = config

      @branch = @config[:branch]

      @data = {
        branch: {
          id: @branch.id,
          name: @branch.name
        },
        centers: []
      }
    end

    def execute!
      centers = Center.where(branch_id: @branch.id).order("name ASC")

      centers.each do |c|
        officer       = c.try(:user)
        active_count  = Member.active.where(center_id: c.id).count
        pending_count = Member.pending.where(center_id: c.id).count

        @data[:centers] << {
          id: c.id,
          name: c.name,
          short_name: c.short_name,
          meeting_day_display: c.meeting_day_display,
          officer: {
            id: officer.try(:id),
            first_name: officer.try(:first_name),
            last_name: officer.try(:last_name)
          },
          active_count: active_count,
          pending_count: pending_count
        }
      end

      @data
    end
  end
end
