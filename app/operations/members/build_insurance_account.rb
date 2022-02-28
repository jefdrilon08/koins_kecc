module Members
  class BuildInsuranceAccount
    attr_accessor :insurance_account,
                  :data

    def initialize(insurance_account:)
      @insurance_account = insurance_account
      
      @data = {
      }
    end

    def execute!
      @data
    end
  end
end
