module Kmba
  class ValidateSaveMembers
    attr_accessor :errors

    def initialize(members:)
      @members  = members

      @errors = []
    end

    def execute!
      if @members.blank?
        @errors << "members not found"
      elsif !@members.kind_of?(Array)
        @errors << "members should be an array"
      else
        @members.each do |o|
          member = JSON.parse(o)
          # Logic to check structure of member
          if !member.kind_of?(Hash)
            @errors << "#{o} is not a hash"
          else
            # stuff to check for member structure
            first_name = o["first_name"]
            last_name = o["last_name"]

            if first_name.blank?
              @errors << "first_name required"
            end

            if last_name.blank?
              @errors << "last_name required"
            end
          end
        end
      end

      @errors
    end
  end
end
