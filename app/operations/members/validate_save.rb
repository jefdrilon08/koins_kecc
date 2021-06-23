module Members
  class ValidateSave < AppValidator
    def initialize(config:)
      super()

      @config       = config
      @member_data  = @config[:member_data]
      @user         = @config[:user]

      @branch = Branch.where(id: @member_data[:branch_id]).first
      @center = Center.where(id: @member_data[:center_id]).first
    end

    def execute!
      # Validate first_name
      if @member_data[:first_name].blank?
        @errors[:messages] << {
          key: "first_name",
          message: "First name required"
        }
      end

      # Validate middle_name
#      if @member_data[:middle_name].blank?
#        @errors[:messages] << {
#          key: "middle_name",
#          message: "Middle name required"
#        }
#      end

      # Validate last_name
      if @member_data[:last_name].blank?
        @errors[:messages] << {
          key: "last_name",
          message: "Last name required"
        }
      end

      # Validate address
      if @member_data[:data][:address][:street].blank?
        @errors[:messages] << {
          key: "address_street",
          message: "Address street required"
        }
      end

      if @member_data[:data][:address][:district].blank?
        @errors[:messages] << {
          key: "address_district",
          message: "Address district required"
        }
      end
      
      # Validate 2nd address
#      if @member_data[:data][:new_address][:street].blank?
#        @errors[:messages] << {
#          key: "address_street",
#          message: "Address street required"
#        }
#      end

#      if @member_data[:data][:new_address][:district].blank?
#        @errors[:messages] << {
#          key: "address_district",
#          message: "Address district required"
#        }
#      end
#      if @member_data[:data][:new_address][:city].blank?
#        @errors[:messages] << {
#          key: "new_address_city",
#          message: "Address city required"
#        }
#      end
#      if @member_data[:data][:new_address][:zip_code].blank?
#        @errors[:messages] << {
#          key: "new_address_zip_code",
#          message: "Address zip code required"
#        }
#      end

      # Validate date of birth
      if @member_data[:date_of_birth].blank?
        @errors[:messages] << {
          key: "date_of_birth",
          message: "Date of birth required"
        }
      end

      # Validate gender
      if @member_data[:gender].blank?
        @errors[:messages] << {
          key: "gender",
          message: "Gender required"
        }
      end

      # Validate civil status
      if @member_data[:civil_status].blank?
        @errors[:messages] << {
          key: "civil_status",
          message: "Civil status required"
        }
      end

      if @member_data[:data][:address][:city].blank?
        @errors[:messages] << {
          key: "address_city",
          message: "Address city required"
        }
      end

      # Validate branch and center
      if @branch.blank?
        @errors[:messages] << {
          key: "branch_id",
          message: "Branch not found"
        }
      end

      if @center.blank?
        @errors[:messages] << {
          key: "center_id",
          message: "Center not found"
        }
      end

      @x = Member.where("last_name = ? and first_name = ? and date_of_birth = ?" , @member_data[:last_name],@member_data[:first_name], @member_data[:date_of_birth]).last
      if @x.present?
        y = Branch.find(@x.branch_id).name
        @errors[:messages] << {
          key: "member_account",
          message: "#{@member_data[:first_name]} #{@member_data[:last_name]} has account already in #{y}"
        }
      end

      #not_yet_implemented!

      @errors[:messages].each do |m|
        @errors[:full_messages] << m[:message]
      end

      @errors
    end
  end
end
