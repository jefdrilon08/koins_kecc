module Api
  module V1
    module Epassbook
      class InsuranceController < ApiEpassbookController
        before_action :authenticate_member_access_token!

        def transactions
          member  = Member.where(access_token: @access_token).first
          account = MemberAccount.where(id: params[:id]).first

          data  = {
            transactions: [],
            account_type: account.account_subtype
          }

          AccountTransaction.where(
            subsidiary_id: account.id,
            subsidiary_type: 'MemberAccount'
          ).order("transacted_at ASC").each do |o|
            data[:transactions] << {
              amount: o.amount,
              beginning_balance: o.data['beginning_balance'],
              ending_balance: o.data['ending_balance'],
              transaction_type: o.transaction_type,
              transacted_at: o.transacted_at.strftime("%B %d, %Y")
            }
          end

          render json: data
        end

        def index
          member  = Member.where(access_token: @access_token).first

          if member.blank?
            render json: { message: "member not found" }, status: 400
          else
            data  = ::Epassbook::FetchMemberInsurance.new(
                      member: member
                    ).execute!

            render json: data
          end
        end
      end
    end
  end
end
