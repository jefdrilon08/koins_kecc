module Members
  class Resign
    def initialize(member:, date_resigned:, resigned_by:, reason:)
      @member         = member
      @date_resigned  = date_resigned
      @resigned_by    = resigned_by
      @member_data    = @member.data.with_indifferent_access
      @reason         = reason
    end

    def execute!
      @member_data[:resignation][:reason] = @reason
      @member_data[:hide_status] = "involuntary"

      @member.update!(data: @member_data)
      @member.update!(
        status: 'resigned', 
        date_resigned: @date_resigned,
        insurance_status: 'resigned',
        insurance_date_resigned: @date_resigned
      )
    end
  end
end
