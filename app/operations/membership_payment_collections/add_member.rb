module MembershipPaymentCollections
  class AddMember
    def initialize(config:)
      @config                         = config
      @membership_payment_collection  = @config[:membership_payment_collection]
      @member                         = @config[:member]

      @data = @membership_payment_collection.data.with_indifferent_access
    end

    def execute!
      # Build member object
      @member_object  = {
        id: @member.id,
        full_name: @member.full_name,
        first_name: @member.first_name,
        middle_name: @member.middle_name,
        last_name: @member.last_name,
        identification_number: @member.identification_number
      }

      # Build member records
      @records  = []
      @data[:headers].each_with_index do |o, i|
        if i == 0
          @records << {
            amount: 0.00,
            enabled: true,
            member_id: @member.id,
            record_type: "ID"
          }
        elsif i == (@data[:headers].size - 1)
          record_type     = "EQUITY"
          account_subtype = o
          member_account  = MemberAccount.where(member_id: @member.id, account_subtype: account_subtype, account_type: record_type).first
          @records << {
            amount: 0.00,
            enabled: true,
            record_type: record_type,
            account_subtype: account_subtype,
            member_account_id: member_account.try(:id)
          }
        else
          @records << {
            amount: 0.00,
            enabled: false,
            member_id: @member.id,
            record_type: "MEMBERSHIP_PAYMENT",
            account_subtype: o
          }
        end
      end

      @data[:records] << {
        member: @member_object,
        records: @records,
        total_collected: 0.00
      }

      @membership_payment_collection.update!(
        data: @data
      )

      @membership_payment_collection
    end
  end
end
