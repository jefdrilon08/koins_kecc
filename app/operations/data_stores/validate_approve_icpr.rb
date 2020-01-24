module DataStores
  class ValidateApproveIcpr < AppValidator
    def initialize(config:)
      super()

      @config     = config
      @data_store = @config[:data_store]
    end

    def execute!
      not_yet_implemented!

      @errors[:messages].each do |e|
        @errors[:full_messages] << e[:message]
      end

      @errors
    end
  end
end
