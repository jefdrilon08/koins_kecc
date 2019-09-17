module MemberAccounts
  module TimeDeposit
    class Autorenew
      def initialize(config:)
        @config         = config
        @member_account = @config[:member_account]
        @branch         = @config[:branch]
        @user           = @config[:user]

        @member = @member_account.member
        @center = @member_account.center
      end

      def execute!
        config  = {
          member_account: @member_account,
          branch: @branch,
          user: @user
        }

        data  = ::MemberAccounts::TimeDeposit::GenerateAutorenewal.new(
                  config: config
                ).execute!

        meta = {
          data_store_type: "TIME_DEPOSIT_AUTORENEWAL",
          member_account: {
            id: @member_account.id,
            balance: @member_account.balance,
            maintaining_balance: @member_account.maintaining_balance,
            account_type: @member_account.account_type,
            account_subtype: @member_account.account_subtype,
            center: {
              id: @center.id,
              name: @center.name
            },
            branch: {
              id: @branch.id,
              name: @branch.name
            },
            member: {
              id: @member.id,
              first_name: @member.first_name,
              middle_name: @member.middle_name,
              last_name: @member.last_name
            }
          }
        }

        data_store  = DataStore.new(
                        meta: meta,
                        data: data,
                        status: "pending"
                      )

        data_store.save!

        data_store
      end
    end
  end
end
