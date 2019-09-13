module Print
  class BuildWithdrawalRequest
    include ActionView::Helpers::NumberHelper

    def initialize(config:)
      @config = config

      @data_store = @config[:data_store]
      @data       = @data_store.data.with_indifferent_access
    end

    def execute!
      @data
    end
  end
end
