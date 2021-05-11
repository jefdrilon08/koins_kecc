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
      @file_valid_id    = @config[:file_valid_id]
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
        file_name: "ID",
        file: @file_valid_id
      )

      @online_application.save!

      @online_application
    end
  end
end
