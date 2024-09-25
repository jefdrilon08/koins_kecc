module ApiReceiveMembers
  class CreateReceiveMembers
    def initialize(config:)
      @config           = config
      @branch_id        = @config[:branch_id]
      @receive_date     = @config[:receive_date]
      @api_from         = @config[:api_from]
      @data             = @config[:data]
      @inforce_count    = @config[:inforce_count].to_i
      @lapsed_count     = @config[:lapsed_count].to_i
      @pending_count    = @config[:pending_count].to_i

    end

    def execute!
      api_receive_member = ApiReceiveMember.new(
        branch_id: @branch_id,
        receive_date: @receive_date,
        api_from: @api_from,
        data: @data,
        status: "pending",
        inforce_count: @inforce_count,
        lapsed_count: @lapsed_count,
        pending_count: @pending_count
      )

      api_receive_member.save!
    end
  end
end
