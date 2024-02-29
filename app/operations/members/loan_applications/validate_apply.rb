module Members
  module LoanApplications
    class ValidateApply < ::Core::Validator
      def initialize(
        member:,
        amount:,
        term:,
        num_installments:,
        loan_product:,
        co_maker_first_name:,
        co_maker_last_name:,
        co_maker_member_id:,
        data: {}
      )
        super()

        @member               = member
        @amount               = amount.try(:to_f).try(:round, 2)
        @term                 = term
        @num_installments     = num_installments
        @loan_product         = loan_product
        @data                 = data
        @co_maker_first_name  = co_maker_first_name
        @co_maker_last_name   = co_maker_last_name
        @co_maker_member_id   = co_maker_member_id

        @payload = {
          member:               [],
          amount:               [],
          term:                 [],
          num_installments:     [],
          date_applied:         [],
          loan_product_id:      [],
          loan_application:     [],
          co_maker_first_name:  [],
          co_maker_last_name:   [],
          co_maker_member_id:   []
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

        if @co_maker_first_name.blank?
          @payload[:co_maker_first_name] << "required"
        end

        if @co_maker_last_name.blank?
          @payload[:co_maker_last_name] << "required"
        end

        if @co_maker_member_id.blank?
          @payload[:co_maker_member_id] << "required"
        end

        if @loan_product.blank?
          @payload[:loan_product_id] << "required"
        end

        if @loan_product.present? and @amount.present?
          if @amount < @loan_product.min_loan_amount
            @payload[:amount] << "invalid amount"
          elsif @amount > @loan_product.max_loan_amount
            @payload[:amount] << "invalid amount"
          end
        end

        if @member.present? and LoanApplication.where(member_id: @member.id, status: 'pending').count > 0
          @payload[:loan_application] << "pending application"
        end

        count_errors!
      end
    end
  end
end
