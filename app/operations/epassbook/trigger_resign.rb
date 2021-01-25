module Epassbook
  class TriggerResign
    def initialize(identification_number:)
      @identification_number  = identification_number
      @url_trigger_resign     = "#{ENV['MY_KOINS_URL']}/api/v1/members/trigger_resign"
    end

    def execute!
      response  = HTTParty.post(
                    @url_trigger_resign,
                    body: {
                      identification_number: @identification_number
                    },
                    headers: {
                      "X-EPASSBOOK-APP-AUTH-SECRET" => ENV['EPASSBOOK_APP_AUTH_SECRET']
                    }
                  ) 

      if response.code.try(:to_s) != "200"
        return false
      else
        return true
      end
    end
  end
end
