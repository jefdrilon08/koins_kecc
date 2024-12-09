module HolidayRecords
    class Delete
      def initialize(config:)
        @holiday_id = config[:holiday_id] 
      end
  
      def execute!
        @holiday_record = HolidayRecord.find_by(id: @holiday_id)
  
        if @holiday_record
          @holiday_record.destroy!

          { message: 'Holiday record successfully deleted' }
        else
          raise "Holiday record not found."
        end
      end
    end
  end