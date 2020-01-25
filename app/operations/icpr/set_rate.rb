module Icpr
  class SetRate
    def initialize(config:)
      @config               = config
      @data_store           = @config[:data_store]
      @equity_interest_rate = @config[:equity_interest_rate]
      @savings_rate         = @config[:savings_rate]
      @cbu_rate             = @config[:cbu_rate]
      @user                 = @config[:user]
      @branch               = Branch.find(@data_store.meta["branch_id"])

      @data = @data_store.data.with_indifferent_access
    end

    def execute!
      @data[:records].each_with_index do |o, i|
        @data[:records][i][:equity_interest_amount] = (@equity_interest_rate * @data[:records][i][:ave_equity])
        @data[:records][i][:savings_distribute]     = (@config[:savings_rate] * @data[:records][i][:equity_interest_amount]).round(2)
        @data[:records][i][:cbu_distribute]         = (@config[:cbu_rate] * @data[:records][i][:equity_interest_amount]).round(2)
        @data[:records][i][:equity_interest_amount] = @data[:records][i][:savings_distribute] + @data[:records][i][:cbu_distribute]
      end

      @data[:equity_interest_rate]  = @equity_interest_rate
      @data[:savings_rate]          = @savings_rate
      @data[:cbu_rate]              = @cbu_rate

      @data[:total_ave_equity]              = @data[:records].inject(0){ |sum, hash| sum + hash[:ave_equity] }.round(2)
      @data[:total_equity_interest_amount]  = @data[:records].inject(0){ |sum, hash| sum + hash[:equity_interest_amount] }.round(2)
      @data[:total_savings_distribute]      = @data[:records].inject(0){ |sum, hash| sum + hash[:savings_distribute] }.round(2)
      @data[:total_cbu_distribute]          = @data[:records].inject(0){ |sum, hash| sum + hash[:cbu_distribute] }.round(2)

      @data[:accounting_entry]  = ::Icpr::BuildAccountingEntry.new(
                                    config: {
                                      branch: @branch,
                                      data: @data,
                                      user: @user
                                    }
                                  ).execute!

      @data_store.update!(data: @data)
    end
  end
end
