module Loans
  class ValidateReage < AppValidator
    def initialize(loan:, approved_by:)
      super()

      @loan         = loan
      @approved_by  = approved_by
    end

    def execute!
      #not_yet_implemented!

      @errors
    end
  end
end
