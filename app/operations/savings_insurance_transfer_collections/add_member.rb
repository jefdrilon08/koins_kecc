module SavingsInsuranceTransferCollections
  class AddMember
    def initialize(config:)
      @config                                 = config
      @savings_insurance_transfer_collection  = @config[:savings_insurance_transfer_collection]
      @member                                 = @config[:member]
      @amount                                 = @config[:amount]
      @user                                   = @config[:user]

      @data   = @savings_insurance_transfer_collection.try(:data).try(:with_indifferent_access)
      @branch = @savings_insurance_transfer_collection.branch

      @savings_subtype    = @data[:savings_subtype]
      @insurance_subtype  = @data[:insurance_subtype]
    end

    def execute!
      @savings_account    = MemberAccount.where(member_id: @member.id, account_subtype: @savings_subtype).first
      @insurance_account  = MemberAccount.where(member_id: @member.id, account_subtype: @insurance_subtype).first

      @data[:records] << {
        member: {
          id: @member.id,
          first_name: @member.first_name,
          middle_name: @member.middle_name,
          last_name: @member.last_name
        },
        savings_account_id: @savings_account.id,
        insurance_account_id: @insurance_account.id,
        amount: @amount,
        savings_account_balance: @savings_account.balance,
        insurance_account_balance: @insurance_account.balance
      }

      total_amount  = @data[:records].inject(0){ |sum, hash| sum + hash[:amount] }.round(2)

      @data[:accounting_entry]  = ::SavingsInsuranceTransferCollections::BuildAccountingEntry.new(
                                    config: {
                                      branch: @branch,
                                      data: @data,
                                      user: @user
                                    }
                                  ).execute!

      @savings_insurance_transfer_collection.update!(data: @data, total_amount: total_amount)

      @savings_insurance_transfer_collection
    end
  end
end
