module BoardResolution
  class ValidateCreate
    def initialize(config:)
      @errors = { messages: [] }
      @config = config
      @branch = @config[:branch]
      @month = @config[:month].upcase
      @year = @config[:year].to_s
      @status = @config[:status]
      @board_resolution_number = @config[:board_resolution_number]
    end

    def execute!
      if DataStore.where(
        "meta ->> 'branch_id' = ? AND meta ->> 'month' = ? AND meta ->> 'year' = ? AND meta ->> 'status' = ? AND meta ->> 'board_resolution_number' = ?",
        @branch.id.to_s, @month, @year, @status, @board_resolution_number
      ).exists?
        @errors[:messages] << {
          key: "board_resolution",
          message: "Board resolution already exists for #{@branch.name}, #{@month} #{@year}, and status #{@status} with a board resolution number of #{@board_resolution_number}"
        }
      end

      # if DataStore.where("meta ->> 'board_resolution_number' = ?", @board_resolution_number).exists?
      #   @errors[:messages] << {
      #     key: "board_resolution_number",
      #     message: "Board resolution number #{@board_resolution_number} already exists."
      #   }
      # end

      @errors[:full_messages] = @errors[:messages].map { |o| o[:message] }
      @errors
    end
  end
end
