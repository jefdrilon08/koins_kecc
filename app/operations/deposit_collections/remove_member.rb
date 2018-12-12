module DepositCollections
  class RemoveMember
    def initialize(config:)
      @config                         = config
      @deposit_collection  = @config[:deposit_collection]
      @member                         = @config[:member]
      @user                           = @config[:user]

      @branch = @deposit_collection.branch
      @data   = @deposit_collection.data.with_indifferent_access

      @default_deposit_accounts = Settings.default_deposit_accounts
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
      @default_deposit_accounts.each do |o|
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
      @data[:accounting_entry]  = ::DepositCollections::BuildAccountingEntry.new(
                                    config: {
                                      branch: @branch,
                                      data: @data,
                                      user: @user
                                    }
                                  ).execute!
      ##########################

      @deposit_collection.update!(
        data: @data
      )

      @deposit_collection
    end
  end
end
