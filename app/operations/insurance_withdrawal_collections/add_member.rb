module InsuranceWithdrawalCollections
  class AddMember
    def initialize(config:)
      @config                 = config
      @insurance_withdrawal_collection  = @config[:insurance_withdrawal_collection]
      @member                 = @config[:member]

      @data = @insurance_withdrawal_collection.data.with_indifferent_access
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
      @data[:totals].each_with_index do |o, i|
        member_account  = MemberAccount.where(member_id: @member.id, account_subtype: o[:key], account_type: o[:record_type]).first
        enabled         = false

        if member_account
          enabled = true
        end

        @records << {
          amount: 0.00,
          enabled: enabled,
          member_id: @member.id,
          record_type: o[:record_type],
          account_subtype: o[:key],
          member_account_id: member_account.id
        }
      end

      @data[:records] << {
        member: @member_object,
        records: @records,
        total_collected: 0.00
      }

      @insurance_withdrawal_collection.update!(
        data: @data
      )

      @insurance_withdrawal_collection
    end
  end
end
