module DepositCollections
  class ValidateLoadBranch < AppValidator
    def initialize(config:)
      super()
      @config = config

      @deposit_collection = @config[:deposit_collection]
      @branch             = @deposit_collection.branch
    end

    def execute!
      if @deposit_collection.blank?
        @errors << {
          name: "deposit_collection",
          message: "Deposit collection not found"
        }
      elsif !@deposit_collection.pending?
        @errors << {
          name: "deposit_collection",
          message: "Deposit collection is not pending"
        }
      end

      if @branch.blank?
        @errors << {
          name: "branch",
          message: "Branch not found"
        }
      else
        member_ids  = @deposit_collection.member_ids

        if Member.active.where(branch_id: @branch.id).where.not(id: member_ids).count == 0
          @errors << {
            name: "branch",
            message: "No members to load"
          }
        end
      end

      #not_yet_implemented!

      @errors[:messages].each do |m|
        @errors[:full_messages] << m[:message]
      end

      @errors
    end
  end
end
