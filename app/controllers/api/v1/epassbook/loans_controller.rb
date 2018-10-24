module Api
  module V1
    module Epassbook
      class LoansController < ApiEpassbookController
        before_action :authenticate_member_access_token!

        def payments
          member  = Member.where(access_token: @access_token).first
          loan    = Loan.where(id: params[:id], member_id: member.id).first

          data  = {
            payments: []
          }

          AccountTransaction.approved_loan_payments.where(
            subsidiary_id: loan.id,
            subsidiary_type: "Loan"
          ).order("transacted_at ASC").each do |o|
            data[:payments] << {
              amount: o.amount,
              transacted_at: o.transacted_at.strftime("%b %d, %Y")
            }
          end

          render json: data
        end

        def active_loans
          member  = Member.where(access_token: @access_token).first

          if member.blank?
            render json: { message: "member not found" }, status: 400
          else
            data  = ::Epassbook::FetchActiveLoans.new(
                      member: member
                    ).execute!

            render json: data
          end
        end

        def show
          member  = Member.where(access_token: @access_token).first
          loan    = Loan.where(id: params[:id]).first

          if member.blank? || loan.blank?
            render json: { message: "resource not found" }, status: 400
          else
            data  = ::Epassbook::FetchLoan.new(
                      member: member,
                      loan: loan
                    ).execute!

            render json: data
          end
        end
      end
    end
  end
end
