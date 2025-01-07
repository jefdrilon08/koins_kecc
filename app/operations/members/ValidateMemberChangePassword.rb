module Members
    class ValidateMemberChangePassword  < AppValidator

      def initialize(config:)
            super()
            @errors = { messages: [] }
            @config = config
            @member = @config[:member]
            @old_password = @config[:old_password]
            @new_password = @config[:new_password]
            @confirm_new_password = @config[:confirm_new_password]

           
      end

      def execute!
        require 'bcrypt'

        #  puts "puts sa ops: #{@member.encrypted_password}"
        #  puts "Old Password sa ops : #{@old_password}"


        if BCrypt::Password.new(@member.encrypted_password) == @old_password
             puts "Passwords match!" 
          else
            puts "Old Password does not match!"
            @errors[:messages] << {
                key: "member",
                message: "Old Password is incorrect"
            }
          end

          if @new_password != @confirm_new_password
            puts "confirm password do not match!"
            @errors[:messages] << {
              key: "member",
              message: "confirmation password do not match"
            }
          end
    
        
         
        
      end
    end
end
