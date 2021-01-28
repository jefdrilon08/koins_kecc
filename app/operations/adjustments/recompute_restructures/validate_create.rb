module Adjustments
  module RecomputeRestructures
    class ValidateCreate < AppValidator
      attr_accessor :errors
      
      def initialize(config:)
        super() 
        @config = config
        @member = @config[:member_id]
        @branch = @config[:branch_id]

        

        @for_member_validation = RecomputeRestructure.where(member: @member, branch: @branch ).count
      
      
      end
      
      def execute!
       if @for_member_validation > 0
          @errors[:messages] << {
            key: "Member",
            message: "Member exist in list"
          }
       end
      

        @errors
      end



    end
  end
end
