module DataStores
  class ValidateForWriteoffQueue < AppValidator
    def initialize(config:)
      super()

      @config = config
      @year   = @config[:year]
      @record = @config[:record]
      @select_number_year = @config[:select_number_year]
    end

    def execute!
      
      if @year.blank?
        @errors[:messages] << {
          key: "year",
          message: "year required"
        }
      end

       if @select_number_year.blank?
        @errors[:messages] << {
          key: "year",
          message: "number year required"
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
