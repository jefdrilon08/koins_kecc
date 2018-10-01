module Api
  module V1
    class SavingsAccountsController < ApiController
      def index
        members = Member.all.order("last_name ASC")

        savings_accounts  = MemberAccount.savings

        data  = []

        savings_accounts.each do |o|
          data << {
            id: o.id,
            member_id: o.member.id,
            member_identification_number: o.member.identification_number,
            member_full_name: o.member.full_name,
            subtype: o.account_subtype,
            balance: o.balance,
            maintaining_balance: o.maintaining_balance
          }
        end

        render json: { savings_accounts: data }
      end
    end
  end
end
