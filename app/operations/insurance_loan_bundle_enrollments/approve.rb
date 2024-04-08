module InsuranceLoanBundleEnrollments
  class Approve
    def initialize(config:)
      @config                                 = config
      @user                                   = @config[:user]
      @insurance_loan_bundle_enrollment       = @config[:insurance_loan_bundle_enrollment]
      @branch                                 = @insurance_loan_bundle_enrollment.branch
      @data                                   = @insurance_loan_bundle_enrollment.data.with_indifferent_access   
      @date_approved  = ::Utils::GetCurrentDate.new(
                          config: {
                            branch: @branch
                          }
                        ).execute!
      
      # @loan = Loan.new(
      #         id: "",
      #         branch_id: @member.branch_id,
      #         center_id: @member.center_id,
      #         date_prepared: @date_approved,
      #         member_id: @member.id,
      #         principal: 5000.00,
      #         loan_product_id: "",
      #         loan_product_type_id: "",
      #         term: "weekly",
      #         pn_number: "",
      #         payment_type: "cash",
      #         num_installments: 25,
      #         project_type_id: "",
      #         status: "pending",
      #         data: {
      #           business_permit_available: false,
      #           advance_insurance_available: false,
      #           clip_beneficiary: {
      #             first_name: "",
      #             middle_name: "",
      #             last_name: "",
      #             date_of_birth: "",
      #             relationship: ""
      #           },
      #           clip_number: "",
      #           voucher: {
      #             bank: "",
      #             bank_check_number: "",
      #             check_number: "",
      #             payee: "",
      #             date_requested: Date.today,
      #             date_of_check: "",
      #             bank_transaction_reference_number: "",
      #             particular: build_default_loan_particular!
      #           },
      #           co_makers: [],
      #           co_maker_three: "",
      #           co_maker_two: "",
      #           co_maker_one: {
      #             id: "",
      #             first_name: "",
      #             middle_name: "",
      #             last_name: ""
      #           }
      #         }
      #       )

    end

    def execute!  
   
      @insurance_loan_bundle_enrollment.update!(
        data: @data,
        approved_by: @user.full_name,
        date_approved: @date_approved
      )
      @insurance_loan_bundle_enrollment
    end

  end
end