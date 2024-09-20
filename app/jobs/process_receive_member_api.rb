class ProcessReceiveMemberApi < ApplicationJob
  queue_as :default

  def perform(members)
    # raise members.inspect

    members.each do |member|
      @identification_number = member["identification_number"]
      @branch_id = member["branch_id"]
      @receive_date = member["receive_date"].to_date
      @api_from = member["api_from"]
      @data = member["data"]

      @inforce_count = @data.count { |d| d["insurance_status"] == "inforce" }
      @lapsed_count = @data.count { |d| d["insurance_status"] == "lapsed" }
      @pending_count = @data.count { |d| d["insurance_status"] == "pending" }

      @api_receive_member = ::ApiReceiveMembers::CreateReceiveMembers.new(
        config: {
          branch_id: @branch_id,
          receive_date: @receive_date,
          api_from: @api_from,
          data: @data,
          inforce_count: @inforce_count,
          lapsed_count: @lapsed_count,
          pending_count: @pending_count
        }
      ).execute!
    end
  end
end
