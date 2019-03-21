module DepositCollections
  class AddMember
    def initialize(config:)
      @config             = config
      @deposit_collection = @config[:deposit_collection]
      @member             = @config[:member]

      @data = @deposit_collection.data.with_indifferent_access

      @default_deposit_accounts = Settings.default_deposit_accounts
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
      @default_deposit_accounts.each_with_index do |o, i|
        member_account  = MemberAccount.where(member_id: @member.id, account_subtype: o.account_subtype, account_type: o.account_type).first
        enabled         = false

        if member_account
          enabled = true
        end

        amount = 0.00

        if Settings.activate_microinsurance
          if member_account.account_subtype == "Retirement Fund"
            amount = 5.00
          elsif member_account.account_subtype == "Life Insurance Fund"
            amount = 15.00
          end
        end

        record_type = o.account_type

        @records << {
          amount: amount,
          enabled: enabled,
          member_id: @member.id,
          record_type: o.account_type,
          account_subtype: o.account_subtype,
          member_account_id: member_account.try(:id)
        }
      end

      @data[:records] << {
        member: @member_object,
        records: @records,
        total_collected: 0.00
      }

      @deposit_collection.update!(
        data: @data
      )

      @deposit_collection
    end
  end
end
