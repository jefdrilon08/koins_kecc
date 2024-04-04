module Members
    class ValidateMemberChangePassword  < AppValidator
      def initialize(config:)
        super()

        @config = config
        @member = @config[:member]
        @old_password = @config[:old_password]
        @new_password = @config[:new_password]
        @confirm_new_password = @config[:confirm_new_password]

        # @valid_roles = ::Users::FetchValidRoles.new(
        #   module_name: "unlock_member_modification"
        # ).execute!
      end

      def execute!
        require 'bcrypt'

        if @member.nil?
            @errors[:messages] << {
                key: "member",
                message: "Member not found."
            }
        end 

        if @old_password.blank?
            @errors[:messages] << {
                key: "old_password",
                message: "old passowrd required"
            }
        else
            if BCrypt::Password.new(@member.encrypted_password) == @old_password
                if @new_password.blank? || @confirm_new_password.blank?
                    if @new_password.blank?
                        @errors[:messages] << {
                            key: "new_password",
                            message: "New passowrd required"
                        }
                    end
        
                    if @confirm_new_password.blank?
                        @errors[:messages] << {
                            key: "confirm_password",
                            message: "Confirm new password required."
                        }
                    end
                    
                else
                    if !(@new_password == @confirm_new_password)
                        @errors[:messages] << {
                            key: "new_confirm_password",
                            message: "Does not match"
                        }
                    end
                end

            else
                @errors[:messages] << {
                    key: "old_password",
                    message: "Incorrect current password."
                }
                
            end

        end
        

        #not_yet_implemented!

        @errors[:messages].each do |o|
          @errors[:full_messages] << o
        end

        @errors
      end
    end
end
