module Accounting
  class ValidateBalanceSheetGenerate < AppValidator
    def initialize(config:)
      super()

      @config = config
      @branch = @config[:branch]
      @year   = @config[:year]
    end

    def execute!
      if @year.blank?
        @errors[:messages] << {
          key: "year",
          message: "year required"
        }
      end

      if @branch.blank?
        @errors[:messages] << {
          key: "branch",
          message: "branch required"
        }
      end

      #not_yet_implemented!

      @errors[:messages].each do |m|
        @errors[:full_messages] << m[:message]
      end

      @errors
    end
  end
end
