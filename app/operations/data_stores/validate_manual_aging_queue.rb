module DataStores
  class ValidateManualAgingQueue < AppValidator
    def initialize(config:)
      super()

      @config = config

      @branch = @config[:branch]
      @as_of  = @config[:as_of].try(:to_date)
    end

    def execute!
      if @branch.blank?
        @errors[:messages] << {
          key: "branch",
          message: "Branch not found"
        }
      end

      if @as_of.blank?
        @errors[:messages] << {
          key: "as_of",
          message: "as_of required"
        }
      end

      #not_yet_implemented!

      @errors[:messages].each do |e|
        @errors[:full_messages] << e[:message]
      end

      @errors
    end
  end
end
