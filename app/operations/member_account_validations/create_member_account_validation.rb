module MemberAccountValidations
  class CreateMemberAccountValidation
    attr_accessor :branch, :date_prepared, :prepared_by, :member_account_validation

    def initialize(branch:, date_prepared:, prepared_by:, is_remote:)
      @branch         = branch
      @date_prepared  = date_prepared
      @prepared_by    = prepared_by
      @is_remote      = is_remote
    end

    def execute!
      build_member_account_validation!
      @member_account_validation
    end

    private

    def build_member_account_validation!
        @member_account_validation = MemberAccountValidation.new(
                                          branch: @branch,
                                          prepared_by: @prepared_by,
                                          date_prepared: @date_prepared,
                                          is_remote: @is_remote
                                          # or_number: "#{Time.now.to_i}-CHANGE-ME"
                                        )

        @member_account_validation
    end
  end
end
