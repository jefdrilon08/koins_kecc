module Dormants
  class ValidateCreate
    def initialize(config:)
      @errors = { messages: [] }
      @config = config
      @branch = @config[:branch]
    end

    def execute!
      if DataStore.where("status = 'pending' and meta ->> 'branch_id' = ? and meta ->> 'data_store_type' = 'DORMANT'", @branch.id).count > 0
        @errors[:messages] << {
          key: "billing",
          message: "Please resolve pending dormancy fee for #{@branch.to_s} before creating a new dormancy collection."
        }
      end

      @errors[:full_messages] = @errors[:messages].map { |o| o[:message] }
      @errors
    end
  end
end