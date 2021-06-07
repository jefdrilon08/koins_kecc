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
        mothers_last_name: "",
        address_province: "",
        address_city: "",
        address_district: "",
        address_street: ""
      }

    end

    def execute!
      @data[:first_name]          = @online_application.first_name
      @data[:middle_name]         = @online_application.middle_name
      @data[:last_name]           = @online_application.last_name
      @data[:mothers_first_name]  = @online_application.data["mothers_first_name"]
      @data[:mothers_middle_name] = @online_application.data["mothers_middle_name"]
      @data[:mothers_last_name]   = @online_application.data["mothers_last_name"]
      @data[:address_province]    = @online_application.data["address"]["province"]
      @data[:address_district]    = @online_application.data["address"]["district"]
      @data[:address_city]        = @online_application.data["address"]["city"]
      @data[:address_street]      = @online_application.data["address"]["street"]

      @data[:logo]  = Base64.strict_encode64(URI.open("#{Rails.root}/app/assets/images/logo_titled.png").read)

      @data
    end
  end
end
