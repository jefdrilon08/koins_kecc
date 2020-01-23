module DataStores
  class ValidateIcprQueue < AppValidator
    def initialize(config:)
      super()

      @config = config
      @year   = @config[:year]
      @record = @config[:record]
    end

    def execute!
      if @year.blank?
        @errors[:messages] << {
          key: "year",
          message: "year required"
        }
      end

      if @record.present? and (@record.approved? or @record.error?)
        @errors[:messages] << {
          key: "record",
          message: "record already existing"
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
