module HolidayRecords
    class Create
        def initialize(config:)
            @config = config
            @holiday_name = @config[:holiday_name]
            @holiday_date = @config[:holiday_date]
            @status = @config[:status]
        end

        def execute!
            @holiday_record = HolidayRecord.new(
                holiday_name: @holiday_name,
                holiday_date: @holiday_date,
                status: @status
            )

            @holiday_record.save!
            @holiday_record
        end
    end
  end
  