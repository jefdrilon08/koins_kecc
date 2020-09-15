module Adjustments
  module Moratoriums
    class ValidateBatchProcess < AppValidator
      attr_accessor :errors

      def initialize(config:)
        super()
        @config = config

        @center = @config[:center]
        @user   = @config[:user]
      end

      def execute!
        if @center.blank?
          @errors[:messages] << {
            key: "center",
            message: "Center required"
          }
        elsif MemberMoratorium.pending.where(center_id: @center.id).count == 0
          @errors[:messages] << {
            key: "center",
            message: "No records to process for #{@center.name}"
          }
        end

        if @user.blank?
          @errors[:messages] << {
            key: "user",
            message: "User required"
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
