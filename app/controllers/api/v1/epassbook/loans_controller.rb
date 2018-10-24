module Api
  module V1
    module Epassbook
      class LoansController < ApiEpassbookController
        include ActionView::Helpers::NumberHelper
        before_action :authenticate_member_access_token!

        def payments
          member  = Member.where(access_token: @access_token).first
          loan    = Loan.where(id: params[:id], member_id: member.id).first

          data  = {
            id: loan.id,
            pn_number: loan.pn_number,
            loan_product: loan.loan_product.to_s,
            payments: []
          }

          balance = loan.total_dues

          AccountTransaction.approved_loan_payments.where(
            subsidiary_id: loan.id,
            subsidiary_type: "Loan"
          ).order("transacted_at ASC").each do |o|
            amount_due  = o["data"]["amount_due"].to_f
            balance -= o.amount

#            o["data"]["amort_entries"].each do |a|
#              amount_due += a["principal_paid"].to_f + a["interest_paid"].to_f
#            end

            data[:payments] << {
              amount_paid: number_to_currency(o.amount, unit: ""),
              amount_due: number_to_currency(amount_due, unit: ""),
              transacted_at: o.transacted_at.strftime("%b %d, %Y"),
              balance: number_to_currency(balance, unit: "")
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
