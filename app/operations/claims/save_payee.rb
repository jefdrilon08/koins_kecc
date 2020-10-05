module Claims
  class SavePayee
    def initialize(config:)
      super()
      @config = config

      @payee              = @config[:payee]
      @claim              = @config[:claim]
      @data               = @claim.data.with_indifferent_access
      @accounting_entry   = @data[:accounting_entry]
    end

    def execute!
      @accounting_entry[:data][:payee]  = @payee

      @data[:accounting_entry]  = @accounting_entry

      @claim.update!(data: @data)

      @claim
    end
  end
end