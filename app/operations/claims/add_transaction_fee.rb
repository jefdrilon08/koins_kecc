module Claims
  class AddTransactionFee
    def initialize(config:)
      @config = config

      @template           = @config[:template]
      @transaction_fee    = @config[:transaction_fee]
      @claim              = @config[:claim]
      @user               = @config[:user]
      @data               = @claim.data.with_indifferent_access
    end

    def execute!
      @data[:claims_template]  = @template
      @data[:transaction_fee]  = @transaction_fee

      config  = {
        claim: @claim,
        branch: @claim.branch,
        user: @user,
        data: @data
      }

      @data[:accounting_entry]  = ::Claims::BuildAccountingEntry.new(
                                    config: config
                                  ).execute!

      @claim.update!(data: @data)
    
      @claim
    end
  end
end
