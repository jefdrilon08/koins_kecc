module Members
  class Fetch
    def initialize(config:)
      @config = config

      @member = Member.where(id: @config[:id]).first
    end

    def execute!
    end
  end
end
