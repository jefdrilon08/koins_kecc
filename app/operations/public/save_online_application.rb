module Public
  class SaveOnlineApplication
    attr_accessor :online_application

    def initialize(config:)
      @config = config

      @first_name       = @config[:first_name]
      @middle_name      = @config[:middle_name]
      @last_name        = @config[:last_name]
      @gender           = @config[:gender]
      @date_of_birth    = @config[:date_of_birth]
      @civil_status     = @config[:civil_status]
      @home_number      = @config[:home_number]
      @mobile_number    = @config[:mobile_number]
      @place_of_birth   = @config[:place_of_birth]
      @religion         = @config[:religion]
      @file_document    = @config[:file_document]
      @data             = @config[:data]

      @online_application = OnlineApplication.new(
                              first_name:     @first_name,
                              middle_name:    @middle_name,
                              last_name:      @last_name,
                              gender:         @gender,
                              date_of_birth:  @date_of_birth,
                              civil_status:   @civil_status,
                              home_number:    @home_number,
                              mobile_number:  @mobile_number,
                              place_of_birth: @place_of_birth,
                              religion:       @religion,
                              data:           @data
                            )
    end

    def execute!
      # files
      @online_application.online_application_documents.build(
        file_name: "OTHERFILE",
        file: @file_document
      )

      @online_application.save!

      notify_user!

      @online_application
    end

    def notify_user!
      ProcessSendOnlineApplicationReferenceNumber.perform_later({
        mobile_number: @online_application.mobile_number,
        first_name: @online_application.first_name,
        last_name: @online_application.last_name,
        reference_number: @online_application.reference_number
      })
    end
  end
end
