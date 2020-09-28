module Claims
  class ModifyBook
    def initialize(config:)
      super()
      @config = config

      @book               = @config[:book]
      @claim              = @config[:claim]
      @data               = @claim.data.with_indifferent_access
      @accounting_entry   = @data[:accounting_entry]
    end

    def execute!
      @accounting_entry[:book]  = @book

      @data[:accounting_entry]  = @accounting_entry

      @claim.update!(data: @data)

      @claim
    end
  end
end
