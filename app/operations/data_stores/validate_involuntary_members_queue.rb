module DataStores
  class ValidateInvoluntaryMembersQueue < AppValidator
    def initialize(config:)
      super()

      @config = config
      @record = @config[:record]

      
     
    end

    def execute!

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
