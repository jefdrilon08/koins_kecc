module Members
  module LoanApplications
    class Apply
      attr_reader :loan_application

      def initialize(
        member:,
        amount:,
        term:,
        num_installments:,
        loan_product:,
        data: {}
      )

        @member           = member
        @amount           = amount
        @term             = term
        @num_installments = num_installments
        @loan_product     = loan_product
        @date_applied     = Date.today
        @data             = data
        @reference_number = Random.hex(3).upcase

        @loan_application = LoanApplication.new(
          member:           @member,
          amount:           @amount,
          loan_product:     @loan_product,
          date_applied:     @date_applied,
          term:             @term,
          num_installments: @num_installments,
          data:             @data,
          reference_number: @reference_number
        )
      end

      def execute!
        @loan_application.save!

        @loan_application
      end
    end
  end
end
