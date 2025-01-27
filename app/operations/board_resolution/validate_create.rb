module BoardResolution
  class ValidateCreate
    def initialize(config:)
      @errors = { messages: [] }
      @config = config
      @branch = @config[:branch]
      @month = @config[:month].upcase
      @year = @config[:year].to_s
      @status = @config[:status]
    end

    def execute!
      if DataStore.where(
        "meta ->> 'branch_id' = ? AND meta ->> 'month' = ? AND meta ->> 'year' = ? AND meta ->> 'status' = ?",
        @branch.id.to_s, @month, @year, @status
      ).exists?
        @errors[:messages] << {
          key: "board_resolution",
          message: "Board resolution already exists for #{@branch.name}, #{@month} #{@year}, and status #{@status}."
        }
      end

      @errors[:full_messages] = @errors[:messages].map { |o| o[:message] }
      @errors
    end
  end
end
