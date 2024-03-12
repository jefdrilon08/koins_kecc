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
        co_maker_first_name:,
        co_maker_last_name:,
        co_maker_member:,
        data: {}
      )
        # project_type_id:

        @member               = member
        @amount               = amount
        @term                 = term
        @num_installments     = num_installments
        @loan_product         = loan_product
        @date_applied         = Date.today
        @data                 = data
        @reference_number     = Random.hex(3).upcase
        @co_maker_first_name  = co_maker_first_name
        @co_maker_last_name   = co_maker_last_name
        @co_maker_member      = co_maker_member
        # @project_type_id      = project_type_id

        @loan_application = LoanApplication.new(
          member:               @member,
          amount:               @amount,
          loan_product:         @loan_product,
          date_applied:         @date_applied,
          term:                 @term,
          num_installments:     @num_installments,
          data:                 @data,
          reference_number:     @reference_number,
          co_maker_first_name:  @co_maker_first_name,
          co_maker_last_name:   @co_maker_last_name,
          co_maker_member:      @co_maker_member,
          # project_type_id:      @project_type_id
        )
      end

      def execute!
        @loan_application.save!

        @loan_application
      end
    end
  end
end
