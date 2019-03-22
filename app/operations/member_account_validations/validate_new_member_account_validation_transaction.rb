module MemberAccountValidations
  class ValidateNewMemberAccountValidationTransaction
    attr_accessor :branch_id, :date_prepared, :errors

    def initialize(branch_id:, date_prepared:)
      @branch              = Branch.where(id: branch_id).first
      @date_prepared       = date_prepared
      @errors              = []
    end

    def execute!
      validate_required_parameters!
      #validate_has_pending_transactions!
      @errors
    end

    private

    def validate_required_parameters!
      if !@branch.present?
        @errors << "Branch required"
      end

      if !@date_prepared.present?
        @errors << "Date prepared required"
      end
    end

    def validate_has_pending_transactions!
      if @branch.present?
        if InsuranceAccountValidation.where(branch_id: @branch.id, status: "pending").count > 0
          @errors << "This branch still has pending transactions"
        end
      end
    end
  end
end