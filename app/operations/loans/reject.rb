module Loans
  class Reject < AppValidator
    attr_accessor :user,
                  :loan

    def initialize(user: nil, loan: nil, reason: nil)
      @user = user
      @loan = loan
    end

    def execute!
      @loan.data["rejection"] = {
        rejected_by: {
          id: @user.id,
          name: @user.full_name,
          first_name: @user.first_name,
          last_name: @user.last_name
        },
        rejected_at: Date.today
      }

      @loan.pn_number = "REJECTED-#{@loan.pn_number}"
      @loan.status    = "rejected"

      @loan.save!
    end
  end
end
