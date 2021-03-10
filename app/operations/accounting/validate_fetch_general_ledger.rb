module Accounting
  class ValidateFetchGeneralLedger < AppValidator
    def initialize(config:)
      super()

      @config     = config
      @start_date = @config[:start_date].try(:to_date)
      @end_date   = @config[:end_date].try(:to_date)
      @branch     = @config[:branch]
    end

    def execute!
      if @start_date.blank?
        @errors[:messages] << {
          key: "start_date",
          message: "start date required"
        }
      end

      if @end_date.blank?
        @errors[:messages] << {
          key: "end_date",
          message: "end_date required"
        }
      end

#      if @branch.blank?
#        @errors[:messages] << {
#          key: "branch",
#          message: "branch required"
#        }
#      end

      # not_yet_implemented!

      @errors[:messages].each do |m|
        @errors[:full_messages] << m[:message]
      end

      @errors
    end
  end
end
