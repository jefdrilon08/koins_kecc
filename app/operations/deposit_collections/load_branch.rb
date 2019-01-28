module DepositCollections
  class LoadBranch
    def initialize(config:)
      @config = config

      @deposit_collection = @config[:deposit_collection]
      @branch             = @deposit_collection.branch
    end

    def execute!
      record_member_ids = @deposit_collection.member_ids
      members_to_add    = Member.active.where.not(
                            id: record_member_ids,
                            branch_id: @branch
                          ).order("last_name ASC")

      members_to_add.each do |member|
        config  = {
          deposit_collection: @deposit_collection,
          member: member
        }

        ::DepositCollections::AddMember.new(
          config: config
        ).execute!
      end

      @deposit_collection
    end
  end
end
