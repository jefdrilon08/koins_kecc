module MonthlyClosingCollections
  class Approve
    def initialize(config:)
      @config = config

      @monthly_closing_collection = @config[:monthly_closing_collection]
      @closing_date               = @monthly_closing_collection.closing_date
      @data                       = @monthly_closing_collection.data.with_indifferent_access
      @user                       = @config[:user]
      @current_date               = Date.today

      # Change this
      @particular = "Interest deposit"
    end

    def execute!
      perform_deposits!

      @monthly_closing_collection.update!(
        status: "approved",
        closed_at: @current_date
      )

      @monthly_closing_collection
    end

    def perform_deposits!
      @data[:records].each do |r|
        member_account  = MemberAccount.find(r[:member_account][:id])
        member          = member_account.member

        config  = {
          date_paid: @closing_date,
          deposit: r,
          member: member,
          user: @user,
          particular: @particular
        }

        ::MonthlyClosingCollections::ApproveDepositHash.new(
          config: config
        ).execute!
      end
    end
  end
end
