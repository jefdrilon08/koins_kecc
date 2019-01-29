module Branches
  class ComputeWatchList
    def initialize(config:)
      @config = config
      @branch = @config[:branch]
      @as_of  = @config[:as_of]

      @data = {
        branch: {
          id: @branch.id,
          name: @branch.name
        },
        as_of: @as_of,
        records: []
      }
    end

    def execute!
    end
  end
end
