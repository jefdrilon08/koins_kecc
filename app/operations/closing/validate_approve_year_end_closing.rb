module Closing
  class ValidateApproveYearEndClosing < AppValidator
    def initialize(config:)
      super()

      @config = config

      @data_store = @config[:data_store]
    end

    def execute!
      if @data_store.blank?
        @errors[:messages] << {
          key: "data_store",
          message: "record not found"
        }
      end

      if @data_store.present? and !@data_store.done?
        @errors[:messages] << {
          key: "data_store",
          message: "Invalid status"
        }
      end

      #not_yet_implemented!

      @errors[:messages].each do |o|
        @errors[:full_messages] << o[:message]
      end

      @errors
    end
  end
end
