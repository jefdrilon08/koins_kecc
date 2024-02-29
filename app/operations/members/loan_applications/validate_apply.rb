module Members
  module LoanApplications
    class ValidateApply < ::Core::Validator
      def initialize(
        member:,
        amount:,
        term:,
        num_installments:,
        loan_product:,
        data: {}
      )
        super()

        @member           = member
        @amount           = amount
        @term             = term
        @num_installments = num_installments
        @loan_product     = loan_product
        @data             = data

        @payload = {
          member:           [],
          amount:           [],
          term:             [],
          num_installments: [],
          date_applied:     [],
          loan_product_id:  [],
          loan_application: []
        }
      end

      def execute!
        if @amount.blank?
          @payload[:amount] << "required"
        end

        if @member.blank?
          @payload[:member] << "required"
        end

        if @term.blank?
          @payload[:term] << "required"
        end

        if @num_installments.blank?
          @payload[:num_installments] << "required"
        end

        if @loan_product.blank?
          @payload[:loan_product_id] << "required"
        end

        if @member.present? and LoanApplication.where(member_id: @member.id, status: 'pending').count > 0
          @payload[:loan_application] << "pending application"
        end

        count_errors!
      end
    end
  end
end
