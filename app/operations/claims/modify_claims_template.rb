module Claims
  class ModifyClaimsTemplate
    def initialize(config:)
      @config = config

      @template           = @config[:template]
      @claim              = @config[:claim]
      @user               = @config[:user]
      @data               = @claim.data.with_indifferent_access
    end

    def execute!
      @data[:claims_template]  = @template

      if @template == ""
        if !@data[:transaction_fee].nil?
          @data[:transaction_fee] = nil
        end
      end

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
