module Members
  class ValidateSave < AppValidator
    def initialize(config:)
      super()

      @config                 = config
      @member_data            = @config[:member_data]
      @user                   = @config[:user]


      @branch                 = Branch.where(id: @member_data[:branch_id]).first
      @center                 = Center.where(id: @member_data[:center_id]).first
      @membership_arrangement = MembershipArrangement.where(id: @member_data[:membership_arrangement_id]).first
      @membership_type        = MembershipType.where(id: @member_data[:membership_type_id]).first
    end

    def execute!

      # Validate Identification Number
      if @member_data[:identification_number].blank?
        @errors[:messages] << {
          key: "identification_number",
          message: "Identification number required"
        }
      end

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
      elsif @member_data[:date_of_birth].present?
        date_of_birth = @member_data[:date_of_birth]
        date_format = Date.parse(date_of_birth)
        age = Date.today.year - date_format.year   
        if age < 18 
          @errors[:messages] << {
            key: "date_of_birth",
            message: "Member Age is not 18 Above"
          }
        end
        if Settings.activate_microinsurance
          if @member_data[:id].present?
            if age > 60 && @recognition_date.present?
              @errors[:messages] << {
                key: "date_of_birth",
                message: "Member Age is 60 Above"
              }
            end
          end
        end
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

      # if @member_data[:data][:address][:city].blank?
      #   @errors[:messages] << {
      #     key: "address_city",
      #     message: "Address city required"
      #   }
      # end

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

      if Settings.activate_microloans
        if @membership_arrangement.blank?
          @errors[:messages] << {
            key: "membership_arrangement_id",
            message: "Membership arrangement not found"
          }
        end
      end

      if @membership_type.blank?
        @errors[:messages] << {
          key: "membership_type_id",
          message: "Membership type not found"
        }
      end

      if Settings.activate_microloans
        if @member_data[:id].empty?
          @member = Member.joins(:branch).where("last_name = ? and first_name = ? and date_of_birth = ?" , @member_data[:last_name],@member_data[:first_name], @member_data[:date_of_birth]).last
          if @member.present?
            @errors[:messages] << {
              key: "member_account",
              message: "#{@member_data[:first_name]} #{@member_data[:last_name]} has account already in #{@member.branch.name}"
            }
          end
        end
      end
      
      #not_yet_implemented!

      @errors[:messages].each do |m|
        @errors[:full_messages] << m[:message]
      end

      @errors
    end
  end
end
