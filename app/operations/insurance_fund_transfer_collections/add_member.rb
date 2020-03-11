module InsuranceFundTransferCollections
  class AddMember
    def initialize(config:)
      @config                             = config
      @insurance_fund_transfer_collection = @config[:insurance_fund_transfer_collection]
      @member                             = @config[:member]
      @user                               = @config[:user]
      @data                               = @insurance_fund_transfer_collection.data.with_indifferent_access
      @default_deposit_accounts           = Settings.default_deposit_accounts
    end

    def execute!
      # Build member object
      @member_object  = {
        id: @member.id,
        full_name: @member.full_name,
        first_name: @member.first_name,
        middle_name: @member.middle_name,
        last_name: @member.last_name,
        identification_number: @member.identification_number,
        center: {
          id: @member.center.id,
          name: @member.center.name
        }
      }

      # Build member records
      @records  = []

      total_collected = 0.00

      @default_deposit_accounts.each_with_index do |o, i|
        member_account  = MemberAccount.where(member_id: @member.id, account_subtype: o.account_subtype, account_type: o.account_type).first
        enabled         = false

        if member_account
          enabled = true
        end

        amount  = 0.00

        if Settings.activate_microinsurance
          defaults  = Settings.try(:defaults).try(:insurance_deposits)

          if defaults.present?
            defaults.each do |o|
              if o.account_subtype == member_account.account_subtype
                amount = o.amount
              end
            end
          end
        end

        total_collected += amount

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
        total_collected: total_collected
      }

      @insurance_fund_transfer_collection.update!(
        data: @data
      )

      if Settings.activate_microinsurance
        r_config = {
          current_member: {
            id: @member.id
          },
          data: @insurance_fund_transfer_collection.data.with_indifferent_access,
          user: @user,
          insurance_fund_transfer_collection: @insurance_fund_transfer_collection
        }

        data  = ::InsuranceFundTransferCollections::RecomputeTotals.new(
                  config: r_config
                ).execute!

        @insurance_fund_transfer_collection.update!(
          data: data
        )
      end

      @insurance_fund_transfer_collection
    end
  end
end
