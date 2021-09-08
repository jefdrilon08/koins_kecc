module Api
  module V2
    class LoansController < ApiController
      before_action :authenticate_api_member!

      include ActionView::Helpers::NumberHelper

      def index
        loans = Loan.select("id, principal, interest, loan_product_id").where(member_id: @member.id)

        if params[:status].present?
          loans = loans.where(status: params[:status])
        end

        data  = loans.map{ |o|
                  {
                    id: o.id,
                    principal: o.principal,
                    interest: o.interest,
                    total: o.principal + o.interest,
                    loan_product: {
                      id: o.loan_product_id,
                      name: o.loan_product.name
                    }
                  }
                }

        render json: { loans: data }
      end

      def project_type_categories
        project_type_categories = ReadOnlyProjectTypeCategory.all.map{ |o|
          {
            id: o.id,
            name: o.name,
            project_types: o.project_types.map{ |p|
              {
                id: p.id,
                name: p.name
              }
            }
          }
        }

        render json: { project_type_categories: project_type_categories }
      end

      def quote
        loan_product          = LoanProduct.find_by_id(params[:loan_product_id])
        amount                = params[:amount].try(:to_f).try(:round, 2)
        term                  = params[:term]
        num_installments      = params[:num_installments].try(:to_i)
        annual_interest_rate  = loan_product.monthly_interest_rate * 12

        result  = ::Finance::Amortize.new(
                    params: {
                      principal: amount,
                      annual_interest_rate: annual_interest_rate,
                      num_installments: num_installments,
                      term: term
                    }
                  ).execute!

        render json: result
      end

      def review
        loan_product      = LoanProduct.find_by_id(params[:loan_product_id])
        pn_number         = "#{SecureRandom.hex(4).upcase}"
        co_maker_one      = Member.find_by_id(params[:co_maker_id])
        project_type      = ProjectType.find_by_id(params[:project_type_id])
        co_maker_two      = params[:co_maker_two].try(:upcase)
        co_maker_three    = params[:co_maker_three].try(:upcase)
        amount            = params[:amount].try(:to_f).try(:round, 2)
        term              = params[:term]
        num_installments  = params[:num_installments].try(:to_i)

        # CLIP related information
        clip_first_name     = params[:clip_first_name]
        clip_middle_name    = params[:clip_middle_name]
        clip_last_name      = params[:clip_last_name]
        clip_date_of_birth  = params[:clip_date_of_birth].try(:to_date)
        clip_relationship   = params[:clip_relationship]
        
        # Project type
        project_type = ProjectType.find_by_id(params[:project_type_id])

        config = {
          loan_product:       loan_product,
          pn_number:          pn_number,
          co_maker_one:       co_maker_one,
          co_maker_two:       co_maker_two,
          co_maker_three:     co_maker_three,
          amount:             amount,
          term:               term,
          num_installments:   num_installments,
          project_type:       project_type,
          member:             @member,
          clip_first_name:    clip_first_name,
          clip_middle_name:   clip_middle_name,
          clip_date_of_birth: clip_date_of_birth,
          clip_relationship:  clip_relationship,
          project_type:       project_type
        }

        validator = ::Loans::ValidateRemoteApply.new(config: config)
        
        validator.execute!

        if validator.errors[:full_messages].any?
          render json: validator.errors, status: 403
        else
          loan = ::Loans::RemoteApply.new(config: config, persist: false).execute!

          data  = ::Loans::BuildRemoteReview.new(
                    member: @member,
                    loan: loan,
                    loan_product: loan_product
                  ).execute!

          render json: data
        end
      end

      def apply
        payload = JSON.parse(params[:payload]).with_indifferent_access

        loan_product      = LoanProduct.find_by_id(payload[:loan_product_id])
        pn_number         = "#{SecureRandom.hex(4).upcase}"
        co_maker_one      = Member.find_by_id(payload[:co_maker_id])
        project_type      = ProjectType.find_by_id(payload[:project_type_id])
        co_maker_two      = payload[:co_maker_two].try(:upcase)
        co_maker_three    = payload[:co_maker_three].try(:upcase)
        amount            = payload[:amount].try(:to_f).try(:round, 2)
        term              = payload[:term]
        num_installments  = payload[:num_installments].try(:to_i)

        # CLIP related information
        clip_first_name     = payload[:clip_first_name]
        clip_middle_name    = payload[:clip_middle_name]
        clip_last_name      = payload[:clip_last_name]
        clip_date_of_birth  = payload[:clip_date_of_birth].try(:to_date)
        clip_relationship   = payload[:clip_relationship]
        
        # Project type
        project_type = ProjectType.find_by_id(payload[:project_type_id])

        co_maker_profile_picture        = params[:co_maker_profile_picture]
        co_maker_three_profile_picture  = params[:co_maker_three_profile_picture]

        config = {
          loan_product:                   loan_product,
          pn_number:                      pn_number,
          co_maker_one:                   co_maker_one,
          co_maker_two:                   co_maker_two,
          co_maker_three:                 co_maker_three,
          amount:                         amount,
          term:                           term,
          num_installments:               num_installments,
          project_type:                   project_type,
          member:                         @member,
          clip_first_name:                clip_first_name,
          clip_middle_name:               clip_middle_name,
          clip_date_of_birth:             clip_date_of_birth,
          clip_relationship:              clip_relationship,
          project_type:                   project_type,
          co_maker_profile_picture:       co_maker_profile_picture,
          co_maker_three_profile_picture: co_maker_three_profile_picture
        }

        validator = ::Loans::ValidateRemoteApply.new(config: config)
        
        validator.execute!

        if validator.errors[:full_messages].any?
          render json: validator.errors, status: 403
        else
          loan = ::Loans::RemoteApply.new(config: config).execute!

          render json: { id: loan.id }
        end
      end
    end
  end
end
