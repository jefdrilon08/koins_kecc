module BillingForWriteoff
    class ValidateCreate < AppValidator
      def initialize(config:)
        super()

        @config = config
        @branch = @config[:branch]
        @user   = @config[:user]
        @year   = @config[:year]
      end

      def execute!
        if @branch.blank?
          @errors[:messages] << {
            key: "branch",
            message: "Branch not found"
          }
        end

        if @year.blank?
           @errors[:messages] << {
            key: "year",
            message: "year not found"
          }
        end

        if @user.blank?
          @errors[:messages] << {
            key: "user",
            message: "User not found"
          }
        end



        #not_yet_implemented!

        @errors[:messages].each do |o|
          @errors[:full_messages] << o[:message]
        end

        @errors
      end
   
  end
end
