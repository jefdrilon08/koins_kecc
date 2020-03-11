module WithdrawalCollections
  class RemoveMember
    def initialize(config:)
      @config                 = config
      @withdrawal_collection  = @config[:withdrawal_collection]
      @member                 = @config[:member]
      @user                   = @config[:user]

      @branch = @withdrawal_collection.branch
      @data   = @withdrawal_collection.data.with_indifferent_access

      @default_withdrawal_accounts = Settings.default_withdrawal_accounts
    end

    def execute!
      # Update records
      new_records = []

      @data[:records].each do |o|
        if o[:member][:id] != @member.id
          new_records << o
        end
      end

      @data[:records] = new_records

      ##########################
  
      # Recompute totals
      @data[:total_collected] = 0.00
      @data[:totals]          = []

      # DEPOSIT
      @default_withdrawal_accounts.each do |o|
        total = 0.00
        @data[:records].each do |r|
          r[:records].each do |rr|
            if rr[:account_subtype] == o.name
              total += rr[:amount].to_f.round(2)
            end
          end
        end

        @data[:totals] << {
          record_type: o.account_type,
          key: o.account_subtype,
          amount: total
        }
      end

      # Load accounting entry
      @data[:accounting_entry]  = ::InsuranceWithdrawalCollections::BuildAccountingEntry.new(
                                    config: {
                                      branch: @branch,
                                      data: @data,
                                      user: @user
                                    }
                                  ).execute!
      ##########################

      @withdrawal_collection.update!(
        data: @data
      )

      @withdrawal_collection
    end
  end
end
