module Api
  class LoansController < ::Api::FrontController
    before_action :authenticate_user!

    def restructure
      co_maker_member = ReadOnlyMember.find_by_id(params[:co_maker_id])
      loan_product    = ReadOnlyLoanProduct.find_by_id(params[:loan_product_id])
      member          = ReadOnlyMember.find_by_id(params[:member_id])
      active_loans    = ReadOnlyLoan.where(id: params[:active_loan_ids])

      config = {
        user:                       @user,
        co_maker:                   params[:co_maker],
        co_maker_member:            co_maker_member,
        loan_product:               loan_product,
        member:                     member,
        pn_number:                  params[:pn_number],
        clip_number:                params[:clip_number],
        date_prepared:              params[:date_prepared],
        num_installments:           params[:num_installments],
        term:                       params[:term],
        active_loans:               active_loans,
        beneficiary_first_name:     params[:beneficiary_first_name],
        beneficiary_middle_name:    params[:beneficiary_middle_name],
        beneficiary_last_name:      params[:beneficiary_last_name],
        beneficiary_date_of_birth:  params[:beneficiary_date_of_birth],
        beneficiary_relationship:   params[:beneficiary_relationship]
      }

      cmd = ::Loans::ValidateRestructure.new(
        config: config
      )

      cmd.execute!

      if cmd.messages.any?
        render json: { errors: cmd.messages }, status: :unprocessable_entity
      else
        cmd = ::Loans::Restructure.new(
          user:                       @user,
          co_maker:                   params[:co_maker],
          co_maker_member:            co_maker_member,
          loan_product:               loan_product,
          member:                     member,
          pn_number:                  params[:pn_number],
          clip_number:                params[:clip_number],
          date_prepared:              params[:date_prepared],
          num_installments:           params[:num_installments],
          term:                       params[:term],
          active_loans:               active_loans,
          beneficiary_first_name:     params[:beneficiary_first_name],
          beneficiary_middle_name:    params[:beneficiary_middle_name],
          beneficiary_last_name:      params[:beneficiary_last_name],
          beneficiary_date_of_birth:  params[:beneficiary_date_of_birth],
          beneficiary_relationship:   params[:beneficiary_relationship]
        )

        cmd.execute!

        render json: { message: "ok" }
      end
    end
  end
end
