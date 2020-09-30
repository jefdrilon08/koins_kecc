module Claims
  class ValidateClaimForPosting < AppValidator
    def initialize(config:)
     super()

      @config = config
      @claim = @config[:claim]
      @branch = @claim.branch
    end

    def execute!
      check_params!
      @errors
    end

    private

    def check_params!
      if @branch.nil?
        @errors[:messages] << {
          key: "claim",
          message: "Branch cant be blank."
        }
      end

      if @claim.date_prepared.nil?
        @errors[:messages] << {
          key: "claim",
          message: "Date Prepared cant be blank."
        }  
      end

      if @claim.status != "for-posting"
        @errors[:messages] << {
          key: "claim",
          message: "Claim needs to be approved."
        }  
      end
    end
  end
end
