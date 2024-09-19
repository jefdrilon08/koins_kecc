module ApiReceiveMembers
  class UpdateMember
    attr_accessor :member

    def initialize(config:)
      @config                     = config
      @center_id                  = @config[:center_id]
      @branch_id                  = @config[:branch_id]
      @identification_number      = @config[:identification_number]
      @first_name                 = @config[:first_name]
      @middle_name                = @config[:middle_name]
      @last_name                  = @config[:last_name]
      @gender                     = @config[:gender]
      @date_of_birth              = @config[:date_of_birth]
      @civil_status               = @config[:civil_status]
      @mobile_number              = @config[:mobile_number]
      @address_street             = @config[:address_street]
      @address_district           = @config[:address_district]
      @address_city               = @config[:address_city]
      @external_ref               = @config[:external_ref]
    end

    def execute!
      member          = Member.find_by(identification_number: @identification_number)
      member_data     = member.data

      member.update!(
        center_id: @center_id,
        branch_id: @branch_id,
        first_name: @first_name,
        middle_name: @middle_name,
        last_name: @last_name,
        gender: @gender,
        date_of_birth: @date_of_birth,
        civil_status: @civil_status,
        mobile_number: @mobile_number,
        external_ref: @external_ref
      )

      member_data["address"]["street"]   = @address_street
      member_data["address"]["district"] = @address_district
      member_data["address"]["city"]     = @address_city

      member.update!(data: member_data) a

    end
  end
end
