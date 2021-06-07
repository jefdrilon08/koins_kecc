module OnlineApplications
  class BuildMemberFormData
    attr_accessor :online_application,
                  :data

    def initialize(online_application:)
      @online_application = online_application

      @data = {
        identification_number: "",
        first_name: "",
        middle_name: "",
        last_name: "",
        mothers_first_name: "",
        mothers_middle_name: "",
        mothers_last_name: ""
      }

    end

    def execute!
      @data[:first_name]          = @online_application.first_name
      @data[:middle_name]         = @online_application.middle_name
      @data[:last_name]           = @online_application.last_name
      @data[:mothers_first_name]  = @online_application.data["mothers_first_name"]
      @data[:mothers_middle_name] = @online_application.data["mothers_middle_name"]
      @data[:mothers_last_name]   = @online_application.data["moethers_last_name"]

      @data[:logo]  = Base64.strict_encode64(URI.open("#{Rails.root}/app/assets/images/logo_titled.png").read)

      @data
    end
  end
end
