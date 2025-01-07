module HolidayRecords
    class Update
      def initialize(config:)
        @config = config
        @holiday_record = HolidayRecordDetail.find(config[:holiday_record_id])
        @holiday_name = @config[:holiday_name]
        @holiday_date = @config[:holiday_date]
        @status = @config[:status]
      end
  
      def execute!
        @holiday_record.update!(
          holiday_name: @holiday_name,
          holiday_date: @holiday_date,
          status: @status
        )
        @holiday_record # Return the updated record
      end
    end
  end