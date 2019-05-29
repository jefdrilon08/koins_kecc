module InsuranceFundTransferCollections
  class RemoveMember
    def initialize(config:)
      @config                              = config
      @insurance_fund_transfer_collection  = @config[:insurance_fund_transfer_collection]
      @member                              = @config[:member]
      @user                                = @config[:user]

      @branch                              = @insurance_fund_transfer_collection.branch
      @data                                = @insurance_fund_transfer_collection.data.with_indifferent_access

      @default_fund_transfer_accounts      = Settings.default_deposit_accounts
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
      @default_fund_transfer_accounts.each do |o|
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

      @insurance_fund_transfer_collection.update!(
        data: @data
      )

      @insurance_fund_transfer_collection
    end
  end
end
