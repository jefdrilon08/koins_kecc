module DepositCollections
  class LoadBranch
    def initialize(config:)
      @config = config

      @deposit_collection = @config[:deposit_collection]
      @branch             = @deposit_collection.branch
      @user               = @config[:user]
    end

    def execute!
      record_member_ids = @deposit_collection.member_ids
      members           = Member.active.where(branch_id: @branch)
      members_to_add    = members.where.not(
                                id: record_member_ids
                                ).order("last_name ASC")
      
      members_to_add.each do |member|
        config  = {
          deposit_collection: @deposit_collection,
          member: member
        }

        ::DepositCollections::AddMember.new(
          config: config
        ).execute!



        @deposit_collection = DepositCollection.find(@deposit_collection.id)

        r_config = {
          current_member: {
            id: member.id
          },
          data: @deposit_collection.data.with_indifferent_access,
          user: @user,
          deposit_collection: @deposit_collection
        }

        data  = ::DepositCollections::RecomputeTotals.new(
                  config: r_config
                ).execute!

        @deposit_collection.update!(data: data)
      end

      @deposit_collection
    end
  end
end
