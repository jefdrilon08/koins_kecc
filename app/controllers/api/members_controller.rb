module Api
  class MembersController < ::Api::ApiController
    before_action :authenticate_member!, except: [:login]

    def login
      username  = params[:username]
      password  = params[:password]

      cmd = ::Members::ValidateLogin.new(
              username: username,
              password: password
            )

      cmd.execute!

      if cmd.errors.any?
        render json: { errors: cmd.errors }, status: :unprocessable_entity
      else
        render json: { token: cmd.token, member: cmd.member.user_object }
      end
    end

    def total_funds
      amount = @member.member_accounts.savings.sum(:balance).to_f

      render json: { amount: amount }
    end

    def total_active_loan_balance
      amount = @member.loans.active.sum("principal_balance + interest_balance").to_f

      render json: { amount: amount }
    end

    def insurance_fund
      amount = @member.member_accounts.insurance.sum(:balance).to_f

      render json: { amount: amount }
    end

    def total_equities
      amount = @member.member_accounts.equities.sum(:balance).to_f

      render json: { amount: amount }
    end

    def active_loans
      cmd = ::Members::GetLoans.new(
              member: @member
            )

      cmd.execute!

      render json: cmd.data
    end
  end
end
