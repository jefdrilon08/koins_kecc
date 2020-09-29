module Claims
  class ModifyParticular
    def initialize(config:)
      super()
      @config = config

      @particular         = @config[:particular]
      @claim              = @config[:claim]
      @data               = @claim.data.with_indifferent_access
      @accounting_entry   = @data[:accounting_entry]
    end

    def execute!
      @accounting_entry[:particular]  = @particular

      @data[:accounting_entry]  = @accounting_entry

      @claim.update!(data: @data)

      @claim
    end
  end
end