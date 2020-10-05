module Claims
  class SaveCheckNumber
    def initialize(config:)
      super()
      @config = config

      @check_number       = @config[:check_number]
      @claim              = @config[:claim]
      @data               = @claim.data.with_indifferent_access
      @accounting_entry   = @data[:accounting_entry]
    end

    def execute!
      @accounting_entry[:data][:check_number]  = @check_number

      @data[:accounting_entry]  = @accounting_entry

      @claim.update!(data: @data)

      @claim
    end
  end
end