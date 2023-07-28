module Members
  class ReclassifiedMember
    def initialize(member:, is_reclassified:)
      @member              = member
      @is_reclassified     = is_reclassified
      @member_data         = @member.data.with_indifferent_access
      
      @member_data[:is_reclassified]
    end

    def execute!
      @member_data[:is_reclassified] = @is_reclassified
      @member.update!(data: @member_data)
    end
  end
end