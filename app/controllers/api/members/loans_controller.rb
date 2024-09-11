module Api
  module Members
    class LoansController < ::Api::V3::ApplicationController
      before_action :authenticate_member!
      before_action :authorize_active_member!
      before_action :load_loan!, only: [:show]

      def load_loan!
        @loan = Loan.find_by_id(
          params[:id]
        )

        if @loan.blank?
          render json: { message: 'not found' }, status: :not_found
        elsif @loan.member_id != @current_member.id
          render json: { message: 'unauthorized' }, status: :unauthorized
        end
      end

      # Loan Application
      def create
        amount              = params[:amount].try(:to_f)
        term                = params[:term]
        num_installments    = params[:num_installments].try(:to_i)
        loan_product        = LoanProduct.find_by_id(params[:loan_product_id])
        co_maker_first_name = params[:co_maker_first_name]
        co_maker_last_name  = params[:co_maker_last_name]
        co_maker_member_id  = params[:co_maker_member_id]
        data                = params[:data] || [:data_cash_flow].try(:to_f)
        project_type_category = params[:project_type_category]
        project_type_id     = params[:project_type_id]

        validator = ::Members::LoanApplications::ValidateApply.new(
          member:               @current_member,
          amount:               amount,
          num_installments:     num_installments,
          term:                 term,
          loan_product:         loan_product,
          co_maker_first_name:  co_maker_first_name,
          co_maker_last_name:   co_maker_last_name,
          co_maker_member_id:   co_maker_member_id,
          data:                 data,
          project_type_category: project_type_category,
          project_type_id:      project_type_id
        )

        validator.execute!

        if validator.valid?
          co_maker_member = Member.find(co_maker_member_id)

          # Added project_type_id field inside data, because no project_type_id field in LoanApplication
          data["project_type_id"] = project_type_id
          data["cash_flow"] = {
                      kita_sa_negosyo: 0.0, 
                      kita_mula_sa_asawa: 0.0, 
                      
                      kita_mula_sa_kasama: 0.0, 
                      iba_pang_pinagkakakitaan: 0.0, 

                      gastos_sa_negosyo: 0.0, 
                      gastos_sa_pagkain: 0.0, 
                      gastos_sa_baon: 0.0, 
                      gastos_sa_gamot: 0.0, 
                      bayarin_sa_tubig: 0.0, 
                      iba_pa: 0.0,

                      hulugan_sa_coop: 0.0,
                      hulugan_bukod_sa_coop: 0.0
          }

          data["so_file"] = {
                    palya_sa_pagiimpok: 0,
                    bilang_ng_absent: 0,
                    tungkulin_bilang_co_maker: '',
                    sit_down: '',
                    kasalukuyang_insurance: ''

          }

          cmd = ::Members::LoanApplications::Apply.new(
            member:               @current_member,
            amount:               amount,
            num_installments:     num_installments,
            term:                 term,
            loan_product:         loan_product,
            co_maker_first_name:  co_maker_first_name,
            co_maker_last_name:   co_maker_last_name,
            co_maker_member:      co_maker_member,
            data:                 data,
            # project_type_id:      project_type_id
          )

          cmd.execute!

          loan_application = cmd.loan_application

          render json: { reference_number: loan_application.reference_number }
        else
          render json: validator.payload, status: :unprocessable_entity
        end
      end

      def index
        status = params[:status] || "active"

        if not Loan::STATUSES.include?(status)
          render json: { message: 'invalid status' }, status: :unprocessable_entity
        else
          cmd = ::Members::GetLoans.new(
            member: @current_member,
            status: status
          )

          cmd.execute!

          render json: cmd.payload
        end
      end

      def show
        cmd = ::Members::BuildLoan.new(loan: @loan)

        cmd.execute!

        render json: cmd.payload
      end
    end
  end
end
