module Dashboard
  class ValidateGenerateAccountingReport < AppValidator
    attr_accessor :errors

    def initialize(config:)
      super()

      @config = config

      @branch_id  = @config[:branch_id]
      @start_date = @config[:start_date]
      @end_date   = @config[:end_date]
    end

    def execute!
      #not_yet_implemented!

      if @branch_id.blank?
        @errors[:messages] << {
          key: "branch_id",
          message: "Branch required"
        }
      end

      if @start_date.blank?
        @errors[:messages] << {
          key: "start_date",
          message: "Start date required"
        }
      end

      if @end_date.blank?
        @errors[:messages] << {
          key: "end_date",
          message: "End date required"
        }
      end

      if @start_date.present? and @end_date.present? and @start_date >= @end_date
        @errors[:messages] << {
          key: "start_date",
          message: "Invalid start_date"
        }
      end
      
      @errors[:messages].each do |m|
        @errors[:full_messages] << m[:message]
      end

      @errors
    end
  end
end
