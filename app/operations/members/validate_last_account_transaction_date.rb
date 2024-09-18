module Members
  class ValidateLastAccountTransactionDate
    def initialize(member:, reinstatement_date:, date_stop:)
      @member                       = member
      @reinstatement_date           = reinstatement_date.to_date
      @date_stop                    = date_stop.to_date
      @member_id                    = @member.id
    end

    def execute!

      if @reinstatement_date.nil?
        raise "Reinstatement Date is blank, Please fill up."
      end
    end
  end
end
