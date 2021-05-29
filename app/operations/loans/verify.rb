module Loans
  class Verify
    attr_accessor :user,
                  :loan

    def initialize(user:, loan:)
      @user = user
      @loan = loan
    end

    def execute!
      @loan.data["verification"] = {
        verified_by: {
          id: @user.id,
          name: @user.full_name,
          first_name: @user.first_name,
          last_name: @user.last_name
        }
      }

      @loan.status = "pending"

      @loan.save!
    end
  end
end
