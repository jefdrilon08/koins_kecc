module AccruedPaymentCollections
  class Delete
    def initialize(config:)
      @config             = config
      @data_store_id      = @config[:data_store_id]
      @date_approved      = ::Utils::GetCurrentDate.new(
                            config: {
                              branch: @branch }).execute!
    end

    def execute!
      AccruedBilling.find(@data_store_id).destroy!
    end


  end
end
