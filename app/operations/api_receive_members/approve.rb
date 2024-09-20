module ApiReceiveMembers
  class Approve
    def initialize(config:)
      @config             = config
      @branch_id          = @config[:branch_id]
      @center_id          = @config[:center_id]
      @receive_date       = @config[:receive_date]
      @data               = @config[:data]


      raise [@branch_id, @center_id, @receive_date].inspect
    end
  end
end
