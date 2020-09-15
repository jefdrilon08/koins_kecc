module Adjustments
  module Moratoriums
    class ValidateProcess < AppValidator
      attr_accessor :errors

      def initialize(config:)
        super()

        @config = config

        @member_moratorium  = @config[:member_moratorium]
        @user               = @config[:user]
      end

      def execute!
        if @user.blank?
          @errors[:messages] << {
            key: "user",
            message: "User required"
          }
        end

        if @member_moratorium.blank?
          @errors[:messages] << {
            key: "member_moratorium",
            message: "Member moratorium required"
          }
        elsif !@member_moratorium.pending?
          @errors[:messages] << {
            key: "member_moratorium",
            message: "Member moratorium should be pending"
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
end
