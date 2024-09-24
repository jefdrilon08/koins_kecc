module ApiReceiveMembers
  class SaveMember
    attr_accessor :member

    def initialize(config:)
      super()
      @config                     = config
      @insurance_status           = @config[:insurance_status]
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
      # raise [@civil_status, @last_name, @date_of_birth].inspect
      member_data = Member.new(
        center_id: @center_id,
        branch_id: @branch_id,
        first_name: @first_name,
        middle_name: @middle_name,
        last_name: @last_name,
        gender: @gender,
        date_of_birth: @date_of_birth,
        civil_status: @civil_status,
        mobile_number: @mobile_number,
        status: "pending",
        insurance_status: @insurance_status,
        external_ref: @external_ref
      )

      a_data = member_data.data = {
        "address" => {
          "street" => @address_street,
          "district" => @address_district,
          "city" => @address_city
        },
        "government_identification_numbers" => {
          "sss_number" => "",
          "pag_ibig_number" => "",
          "phil_health_number" => "",
          "tin_number" => ""
        },
      }

      member_data.save!
    end
  end
end
