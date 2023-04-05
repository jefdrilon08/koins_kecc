module Kmba
  class ValidateSaveMembers < AppValidator 
    def initialize(config:)
      super()

      @config               = config
    end

    def execute!
      #validate the member_data

      raise @config.inspect
      
      # if @config["id"].blank?
      #   @errors[:messages] << {
      #     key: "id", 
      #     message: "members not found"
      #   }
      # end

      # if @member_data[:data][:address][:street].blank?
      #   @errors[:messages] << {
      #     key: "address_street",
      #     message: "Address street required"
      #   }
      # end

      # if @member_data[:data][:address][:district].blank?
      #   @errors[:messages] << {
      #     key: "address_district",
      #     message: "Address district required"
      #   }
      # end
      #validate the first_name
      # if @member_data[:first_name].blank?
      #   @errors[:messages] << {
      #     key: "first_name",
      #     message: "First Name not Found"
      #   }
      # end 

      # #validate the middle_name
      # # if @members_data[:middle_name].blank?  
      # #   @errors << "Middle Name not Found"
      # # end
      
      # if @member_data[:last_name].blank?
      #   @errors[:messages] << {
      #     key: "last_name",
      #     message: "Last Name not Found"
      #   }
      # end

      #  if @member_data[:identification_number].blank?
      #   @errors[:messages] << {
      #     key: "identification_number",
      #     message: "Identification Number not Found"
      #   }
      # end 

      # if @member_data[:gender].blank?
      #   @errors[:messages] << {
      #     key: "gender",
      #     message: "Gender not Found"
      #   }
      # end

      # if @member_data[:date_of_birth].blank?
      #   @errors[:messages] << {
      #     key: "date_of_birth",
      #     message: "Date of Birth is Empty"
      #   }
      # end

      # if @member_data[:civil_status].blank?
      #   @errors[:messages] << {
      #     key: "civil_status",
      #     message: "Civil Status not Found"
      #   }
      # end

      # if @member_data[:member_type].blank?
      #   @errors[:messages] << {
      #     key: "member_type",
      #     message: "Member Type not Found"
      #   }
      # end

      # if @member_data[:data][:address][:street].blank?
      #   @errors[:messages] << {
      #     key: ":data:address:street",
      #     message: "Address, street not Found"
      #   }
      # end

      # if @member_data[:data][:address][:district].blank?
      #   @errors[:messages] << {
      #     key: ":data:address:district",
      #     message: "Address, district not Found"
      #   }
      # end

      @errors[:messages].each do |o|
        @errors[:full_messages] << o[:message]
      end

      @errors  
    end
  end
end