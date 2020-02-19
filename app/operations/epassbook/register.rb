module Epassbook
  class Register
    attr_accessor :member, :success, :errors

    def initialize(member:)
      @member   = member
      @success  = false
      @errors   = []

      @url  = "#{ENV['MY_KOINS_URL']}/api/v1/users/register"
    end

    def success?
      success
    end

    def execute!
      # Generate access token if member doesn't have one yet
      if @member.access_token.blank?
        @member.update!(access_token: "#{SecureRandom.hex(32)}")
      end

      data  = {
        first_name: @member.first_name,
        middle_name: @member.middle_name,
        last_name: @member.last_name,
        identification_number: @member.identification_number,
        api_key: @member.access_token,
        branch_uuid: @member.branch.id
      }

      options = {
        body: data
      }

      response  = HTTParty.post(@url, options)

      response_data = JSON.parse(response.body)

      if response.code.try(:to_s) != "200"
        @errors   = response_data["errors"]
        @success  = false
      else
        @success  = true
      end
    end
  end
end
