module OnlineApplications
  class BuildMemberFormData
    attr_accessor :online_application,
                  :data

    def initialize(online_application:)
      @online_application = online_application

      @data = {
        first_name: "",
        middle_name: "",
        last_name: ""
      }

    end

    def execute!
      @data[:logo]  = Base64.strict_encode64(URI.open("#{Rails.root}/app/assets/images/logo_titled.png").read)

      @data
    end
  end
end
