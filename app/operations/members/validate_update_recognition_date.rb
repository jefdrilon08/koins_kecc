module Members
  class ValidateUpdateRecognitionDate
    def initialize(member:, previous_recognition_date:, update_recognition_date:, user:)
      @member                        = member
      @previous_recognition_date     = previous_recognition_date
      @update_recognition_date       = update_recognition_date
      @user                          = user
      @valid_roles                   = ["MIS", "AO"]
      @errors                        = []

    end

    def execute!
      if !@update_recognition_date.present?
        @errors << "Updated Recognition Date is required!"
      end

      if (@user.roles & @valid_roles).size == 0
        @errors << "Your Account is not authorized, user account role is #{@user.roles}"
      end

      @errors
    end
  end
end
