module CommissionCollections
  class SaveCheckVoucherNumber
    def initialize(config:)
      super()
      @config = config

      @check_voucher_number       = @config[:check_voucher_number]
      @commission_collection      = @config[:commission_collection]
      @data                       = @commission_collection.data.with_indifferent_access
      @accounting_entry           = @data[:accounting_entry]
    end

    def execute!
      @accounting_entry[:data][:check_voucher_number]  = @check_voucher_number

      @data[:accounting_entry]  = @accounting_entry

      @commission_collection.update!(data: @data)

      @commission_collection
    end
  end
end