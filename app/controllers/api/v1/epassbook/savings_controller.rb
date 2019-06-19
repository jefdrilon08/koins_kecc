module Api
  module V1
    module Epassbook
      class SavingsController < ApiEpassbookController
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
          ).where(
            "EXTRACT(year FROM transacted_at) = ?",
            Date.today.year
          ).order("transacted_at DESC, created_at DESC").each do |o|
            interest_html = ""

            if o.data["is_interest"] == true
              interest_html = "<span class='badge badge-success'>Interest</span>"
            end

            data[:transactions] << {
              amount: o.amount,
              beginning_balance: o.data['beginning_balance'],
              ending_balance: o.data['ending_balance'],
              transaction_type: o.transaction_type,
              transacted_at: o.transacted_at.strftime("%B %d, %Y"),
              interest_html: interest_html
            }
          end

          render json: data
        end

        def index
          member  = Member.where(access_token: @access_token).first

          if member.blank?
            render json: { message: "member not found" }, status: 400
          else
            data  = ::Epassbook::FetchMemberSavings.new(
                      member: member
                    ).execute!

            render json: data
          end
        end
      end
    end
  end
end
