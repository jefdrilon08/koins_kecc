module DataStores
  class ValidateForWriteoffQueue < AppValidator
    def initialize(config:)
      super()

      @config = config
      @year   = @config[:year]
      @number_year = @config[:number_year]
      @record = @config[:record]
     
    end

    def execute!
      
      if @year.blank?
        @errors[:messages] << {
          key: "year",
          message: "year required"
        }
      end

      if @number_year.blank?
        @errors[:messages] << {
          key: "number_year",
          message: "number of years required"
        }
      end



      if @record.present?
       
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
