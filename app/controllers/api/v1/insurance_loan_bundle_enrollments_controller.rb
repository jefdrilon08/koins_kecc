module Api
  module V1
    class InsuranceLoanBundleEnrollmentsController < ApiController
      before_action :authenticate_user!

      def approve
    
        # online_application  = LoanApplication.find(params[:id])
        insurance_loan_bundle_enrollment = InsuranceLoanBundleEnrollment.where(id: params[:id]).first
        data = insurance_loan_bundle_enrollment.data.with_indifferent_access["records"].last
        data_premium = data.with_indifferent_access["kok_data"]["premium_coverage"]
        # raise data_premium.inspect
        # online_application_data = Member.find(online_application.member_id)

        member = Member.find(insurance_loan_bundle_enrollment.member_ids)
        # branch_id = member.branch_id

        
        # member = Member.find(online_application.member_id)
        # sco_maker = Member.find(insurance_loan_bundle_enrollment.co_maker_member_id) 
        loan_data = {
                      id: nil,
                      branch_id: insurance_loan_bundle_enrollment.branch_id,
                      center_id: insurance_loan_bundle_enrollment.center_id,
                      date_prepared: "2024-03-01",
                      member_id: insurance_loan_bundle_enrollment.member_ids,
                      principal: data_premium,
                      loan_product_id: "29a8e8a4-56f5-4aeb-ad49-0b0cd1bcda0a",
                      term: "weekly",
                      pn_number: "00",
                      num_installments: 25,
                      # project_type_id: insurance_loan_bundle_enrollment.data['project_type_id'],
                      status: "pending",
                      data: {
                              voucher:{
                                        bank:"",
                                        bank_check_number: "",
                                        check_number: "",
                                        payee:"",
                                        date_requested: "",
                                        date_of_check: "",
                                        particular: ""
                                      },
                              co_maker_two: "",
                              co_maker_one: {
                                value: "",
                                label: "",
                                id: "",
                                first_name: "" , 
                                middle_name: "",
                                last_name: ""
                              },
                              # clip_beneficiary: {
                              #   first_name: insurance_loan_bundle_enrollment.data['clip_beneficiary']['first_name'],
                              #   middle_name: insurance_loan_bundle_enrollment.data['clip_beneficiary']['middle_name'],
                              #   last_name: insurance_loan_bundle_enrollment.data['clip_beneficiary']['last_name'],
                              #   date_of_birth: "",
                              #   relationship: ""

                              # }
                            }
                    }

        config  = { 
                    loan_data: loan_data, 
                    insurance_loan_bundle_enrollment: insurance_loan_bundle_enrollment,
                    user: current_user, 
                    co_maker_profile_picture: nil, 
                    co_maker_three_profile_picture: nil 
                  } 

        data = ::Loans::Save.new(config: config).execute!
        insurance_loan_bundle_enrollment.update!(status: "approved")
        args  = {
            id: insurance_loan_bundle_enrollment.id,
            user_id: current_user.id
          }
        ProcessApproveInsuranceLoanBundleEnrollment.perform_later(args)
        render json: { message: "ok" }
      
      end


      # def approve
      #   insurance_loan_bundle_enrollment = InsuranceLoanBundleEnrollment.where(id: params[:id]).first
      #   # @record_id = insurance_loan_bundle_enrollment.data.with_indifferent_access["records"][0]["member"]["id"]
      #   config  = {
      #     insurance_loan_bundle_enrollment: insurance_loan_bundle_enrollment,
      #     user: current_user
      #   }

      #   errors  = ::InsuranceLoanBundleEnrollments::ValidateApprove.new(
      #               config: config
      #             ).execute!


      #   if errors[:full_messages].any?
      #     render json: { errors: errors }, status: 400
      #   else
      #     insurance_loan_bundle_enrollment.update!(status: "processing")

      #     args  = {
      #       id: insurance_loan_bundle_enrollment.id,
      #       user_id: current_user.id
      #     }

      #     ProcessApproveInsuranceLoanBundleEnrollment.perform_later(args)

      #     render json: { message: "ok" }
      #   end
      # end

      def check
        insurance_loan_bundle_enrollment = InsuranceLoanBundleEnrollment.find(params[:id])

        config = {
          insurance_loan_bundle_enrollment: insurance_loan_bundle_enrollment,
          user: current_user
        }
       
        if ["MIS", "AO"].include? current_user.roles.last
          errors  = InsuranceLoanBundleEnrollments::ValidateCheck.new(
                      config: config
                    ).execute!

          if errors[:messages].any?
            render json: { errors: errors }, status: 400
          else
            insurance_loan_bundle_enrollment  = InsuranceLoanBundleEnrollments::Check.new(
                                        config: config
                                      ).execute!

            render json: { message: "Successfully proceed" }
          end
        else
          errors << "Unauthorized to perform this transaction"

          render json: { message: "Unauthorized", errors: errors }, status: 401
        end
      end

      def declined
        insurance_loan_bundle_enrollment = InsuranceLoanBundleEnrollment.find(params[:id])
        config = {
          insurance_loan_bundle_enrollment: insurance_loan_bundle_enrollment,
          user: current_user
        }

        if ["MIS", "OAS", "FM"].include? current_user.roles.last
          errors  = InsuranceLoanBundleEnrollments::ValidateDecline.new(
                      config: config
                    ).execute!
   
          if errors[:messages].any?
            render json: { errors: errors }, status: 400
          else
            insurance_loan_bundle_enrollment  = InsuranceLoanBundleEnrollments::Declined.new(
                                        config: config
                                      ).execute!

            render json: { message: "Successfully proceed claim" }
          end
        else
          errors << "Unauthorized to perform this transaction"
          render json: { message: "Unauthorized", errors: errors }, status: 401
        end
      end


      def remove_member
        insurance_loan_bundle_enrollment = InsuranceLoanBundleEnrollment.where(id: params[:id]).first
        member                                = Member.where(id: params[:member_id]).first
        member_index                          = params[:member_id]

        config  = {
          insurance_loan_bundle_enrollment: insurance_loan_bundle_enrollment,
          member_index: member_index,
          user: current_user
        }
          ::InsuranceLoanBundleEnrollments::RemoveMember.new(
            config: config
          ).execute!

          render json: { message: "ok" }
        #end
      end

       def add_member
        insurance_loan_bundle_enrollment = InsuranceLoanBundleEnrollment.where(id: params[:id]).first
        member                           = Member.where(id: params[:member_id]).first
        plan_type                        = params[:plan_type]
        plan_category                    = params[:plan_category]
        partner                          = params[:partner]
        policy_no                        = params[:policy_no]
        effectivity_date                 = params[:effectivity_date]
        maturity_date                    = params[:maturity_date]
        client_type                      = params[:client_type]
        first_name                       = params[:first_name]
        middle_name                      = params[:middle_name]
        last_name                        = params[:last_name]
        address                          = params[:address]
        gender                           = params[:gender]
        enrolled_status                  = params[:enrolled_status]
        civil_status                     = params[:civil_status]
        birth_date                       = params[:birth_date]
        age                              = params[:age]
        premium_coverage                 = params[:premium_coverage]
        mobile_no                        = params[:mobile_no]
        membership_date                  = params[:membership_date]
        benif_fname                      = params[:benif_fname]
        benif_mname                      = params[:benif_mname]
        benif_lname                      = params[:benif_lname]
        benif_birth_date                 = params[:benif_birth_date]
        benif_gender                     = params[:benif_gender]
        benif_relationship               = params[:benif_relationship]

                  config  = {
                    insurance_loan_bundle_enrollment: insurance_loan_bundle_enrollment,
                    plan_type: plan_type,
                    plan_category: plan_category,
                    partner: partner,
                    policy_no: policy_no,
                    effectivity_date: effectivity_date,
                    maturity_date: maturity_date,
                    client_type: client_type,
                    first_name: first_name,
                    middle_name: middle_name,
                    last_name: last_name,
                    address: address,
                    gender: gender,
                    enrolled_status: enrolled_status,
                    civil_status: civil_status,
                    birth_date: birth_date,
                    age: age,
                    premium_coverage: premium_coverage,
                    mobile_no: mobile_no,
                    membership_date: membership_date,
                    benif_fname: benif_fname,
                    benif_mname: benif_mname,
                    benif_lname: benif_lname,
                    benif_birth_date: benif_birth_date,
                    benif_gender: benif_gender,
                    benif_relationship: benif_relationship,
                    member: member,
                    user: current_user
                  }
        
        errors  = ::InsuranceLoanBundleEnrollments::ValidateAddMember.new(
                    config: config
                  ).execute!

        if errors[:full_messages].any?
          render json: { errors: errors }, status: 400
        else
          ::InsuranceLoanBundleEnrollments::AddMember.new(
            config: config
          ).execute!

          render json: { message: "ok" }
        end
      end

      def save
        branch            = Branch.where(id: params[:branch_id]).first
        center            = Center.where(id: params[:center_id]).first
        collection_date   = params[:collection_date]
        
        config  = {
          branch: branch,
          center: center,
          collection_date: collection_date,
          user: current_user
        }

        errors  = ::InsuranceLoanBundleEnrollments::ValidateSave.new(
                    config: config
                  ).execute!

        if errors[:full_messages].any?
          render json: { errors: errors }, status: 400
        else
          insurance_loan_bundle_enrollment = ::InsuranceLoanBundleEnrollments::Save.new(
                                                    config: config
                                                  ).execute!

          render json: { message: "ok", id: insurance_loan_bundle_enrollment.id }
        end
 
      end
    end
  end
end