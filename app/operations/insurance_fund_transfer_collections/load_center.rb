module InsuranceFundTransferCollections
  class LoadCenter
    def initialize(config:)
      @config = config

      @insurance_fund_transfer_collection = @config[:insurance_fund_transfer_collection]
      @center                             = @config[:center]
      @user                               = @config[:user]
      # raise @user.inspect
    end

    def execute!
      record_member_ids = @insurance_fund_transfer_collection.member_ids
      members           = Member.active.where(center_id: @center.id, insurance_status: "inforce")
      members_to_add    = members.where.not(
                            id: record_member_ids
                          ).order("last_name ASC")
      
      members_to_add.each do |member|
        config  = {
          insurance_fund_transfer_collection: @insurance_fund_transfer_collection,
          member: member,
          user: @user
        }

        ::InsuranceFundTransferCollections::AddMember.new(
          config: config
        ).execute!

        @insurance_fund_transfer_collection = InsuranceFundTransferCollection.find(@insurance_fund_transfer_collection.id)

        r_config = {
          current_member: {
            id: member.id
          },
          data: @insurance_fund_transfer_collection.data.with_indifferent_access,
          user: @user,
          insurance_fund_transfer_collection: @insurance_fund_transfer_collection
        }

        data  = ::InsuranceFundTransferCollections::RecomputeTotals.new(
                  config: r_config
                ).execute!

        @insurance_fund_transfer_collection.update!(data: data)
      end

      @insurance_fund_transfer_collection
    end
  end
end
