module MemberAccounts
  module TimeDeposit
    class ValidateRequestTimeDepositWithdrawal < AppValidator
      def initialize(config:)
        super()

        @config         = config
        @member_account = @config[:member_account]
        @branch         = @config[:branch]
        @user           = @config[:user]
      end

      def execute!
        if @member_account.blank?
          @errors[:messages] << {
            key: "member_account",
            message: "Member account not found"
          }
        else
          withdrawal_requests = ::MemberAccounts::TimeDeposit::FetchWithdrawalRequests.new(
                                  config: {
                                    member_account: @member_account
                                  }
                                ).execute!

          pending_requests  = withdrawal_requests[:records].select{ |o|
                                o[:status] == "pending"
                              }

          if pending_requests.size > 0
            @errors[:messages] << {
              key: "member_account",
              message: "account still has pending requests"
            }
          end
        end

        if @branch.blank?
          @errors[:messages] << {
            key: "branch",
            message: "branch not found"
          }
        end

        if @user.blank?
          @errors[:messages] << {
            key: "user",
            message: "user not found"
          }
        end

        #not_yet_implemented!

        @errors[:messages].each do |o|
          @errors[:full_messages] << o[:message]
        end

        @errors
      end
    end
  end
end
